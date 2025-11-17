//
//  AlbumService.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-13.
//

//Fetches and saves album from/to Firestore per each logged-in user. (2025-11-15)

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AlbumService: ObservableObject {
    static let shared = AlbumService()
    @Published var albums: [Album] = []
    private let db = Firestore.firestore()
    
    func fetchAlbumsFromUser(completion: @escaping (Result<[Album], Error>) -> Void) {
        //This is important to retrieve logged user song and albums only
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(SimpleError("No user logged in")))
        }
        
        db.collection("users")
          .document(uid)
          .collection("albums")
          .getDocuments { snap, error in

            if let error = error {
                return completion(.failure(error))
            }

            let items = snap?.documents.compactMap {
                try? $0.data(as: Album.self)
            } ?? []

            DispatchQueue.main.async { self.albums = items }
            completion(.success(items))
        }
    }
    
    func saveAlbum(_ album: Album, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(SimpleError("No user logged in"))
        }

        let id = album.id ?? UUID().uuidString
        var albumWithID = album
        albumWithID.id = id

        do {
            try db.collection("users")
                .document(uid)
                .collection("albums")
                .document(id)
                .setData(from: albumWithID)

            self.albums.append(albumWithID)
            completion(nil)

        } catch {
            completion(error)
        }
    }
}
