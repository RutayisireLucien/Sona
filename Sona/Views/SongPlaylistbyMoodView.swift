//
//  SongPlaylistbyMoodView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// // Shows now songs for a mood, fetched from Firestore only for the current user. (2025-11-15)

import FirebaseAuth
import SwiftUI

struct SongPlaylistByMoodView: View {
    let mood: Mood
    @ObservedObject private var songService = SongService.shared
    @State private var songs: [Song] = []
    
    var body: some View {
        ZStack {
            Color(mood.colorName)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("\(mood.name) Playlist")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding([.top, .horizontal])
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(songs, id: \.id) { song in
                            NavigationLink(destination: NowPlayingView(mood: mood, startSong: song, songs: songs)) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(song.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(song.artist)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black.opacity(0.25))
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchSongsForMood()
        }
    }
    
    //Added by Alvaro
    private func fetchSongsForMood() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        guard let moodID = mood.id else { return }
        
        songService.fetchSongsByMood(moodID, userID: uid) { result in
            switch result {
            case .success(let fetchedSongs):
                self.songs = fetchedSongs
            case .failure(let error):
                print("Error fetching songs: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    SongPlaylistByMoodView(mood: Mood(id: "1", name: "Happy", emoji: "😄", description: "", colorName: "happyColor"))
}
