//
//  SongPlaylistbyMoodView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct SongPlaylistByMoodView: View {
    let mood: Mood
    var songs: [Song] {
        DummyData.songs.filter { $0.moodID == mood.id }
    }
    
    var body: some View {
        ZStack {
            // background color from mood
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
                            NavigationLink(destination: NowPlayingView(song: song, mood: mood))
                                {
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
                                    RoundedRectangle(cornerRadius: 15)    .fill(Color.black.opacity(0.25))
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    SongPlaylistByMoodView(mood: DummyData.moods.first!)
}
