//
//  SongService.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-13.
//
// Fetches songs by mood from Firestore, and creates it own collection per user. (2025-11-15)

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class SongService: ObservableObject {
    static let shared = SongService()
    
    @Published var allSongs: [Song] = []
    @Published var songsByMood: [Song] = []
    @Published var songsByAlbum: [Song] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    init() {}
    
    func fetchSongsByMood(_ moodID: String, userID: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        
        db.collection("users")
            .document(userID)
            .collection("songs")
            .whereField("moodID", isEqualTo: moodID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let list = snapshot?.documents.compactMap {
                    try? $0.data(as: Song.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self.songsByMood = list
                }
                
                completion(.success(list))
            }
    }
        
    func saveSong(_ song: Song, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(SimpleError("No user logged in")))
        }

        let id = song.id ?? UUID().uuidString
        
        do {
            try db.collection("users").document(uid)
                .collection("songs")
                .document(id)
                .setData(from: song) { error in

                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
}
