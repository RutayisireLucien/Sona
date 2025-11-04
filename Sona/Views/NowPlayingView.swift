//
//  NowPlayingView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct NowPlayingView: View {
    let song: Song
    let mood: Mood
    
    @State private var isPlaying = false
    @State private var isFavourite = false
    @State private var progress: Double = 0.78 // just for now
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(mood.colorName),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Top section with back + favourite

                // ALBUM ART
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 320, height: 320)
                        .shadow(color: .white.opacity(0.1), radius: 15)
                }
                
                // SONG DATA
                VStack(spacing: 8) {
                    Text(song.title)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(song.artist)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // PROGRESS BAR (JUST SAMPLE)
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isFavourite.toggle()
                            }
                        } label: {
                            Image(systemName: isFavourite ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(isFavourite ? .red : .white)
                                .shadow(color: .black.opacity(0.4), radius: 5)
                        }
                        .padding()
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .padding(.horizontal)
                    HStack {
                        // SAMPLE DATA ONLY
                        Text("1:24")
                        Spacer()
                        Text("3:45")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                }
                
                // CONTROLS (WITHOUT LOGIC)
                HStack(spacing: 60) {
                    Button {
                        // LOGIC FOR PREVIOUS TRACK ==> TODO
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .shadow(radius: 8)
                    }
                    
                    Button {
                        // LOGIC FOR NEX TRACK ==> TODO
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
    }
}

#Preview {
    NowPlayingView(song: DummyData.songs.first!, mood: DummyData.moods.first!)
}
