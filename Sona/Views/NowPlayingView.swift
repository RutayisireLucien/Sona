//
//  NowPlayingView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI
import AVFoundation

struct NowPlayingView: View {
    private let songs = DummyData.songs
    let mood: Mood
    let startSong: Song?
    
    @State private var currentIndex: Int = 0
    @State private var isPlaying = false
    @State private var isFavourite = false
    @State private var progress: Double = 0.0
    @State private var transitionDirection: Edge = .top // for up/down animation (Differing from spotify and apple on purpose.)
    @State private var audioPlayer: AVAudioPlayer?
    
    init(mood: Mood, startSong: Song? = nil) {
        self.mood = mood
        self.startSong = startSong
        
        if let startSong = startSong,
           let index = DummyData.songs.firstIndex(where: { $0.id == startSong.id }) {
            _currentIndex = State(initialValue: index)
        } else {
            _currentIndex = State(initialValue: 0)
        }
    }
    
    
    var body: some View {
        let song = songs[currentIndex]//Ignore the warning, its used for the animation function.
        
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(mood.colorName),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            //Animated
            VStack(spacing: 40) {
                ZStack {
                    ForEach(Array(songs.enumerated()), id: \.offset) { index, s in
                        if index == currentIndex {
                            movingSongContent(for: s)
                                .transition(.move(edge: transitionDirection)
                                    .combined(with: .opacity))
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                
                //COntent that stays in place
                VStack(spacing: 20) {
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
                        .padding(.trailing)
                    }
                    
                    // Progress bar + times
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .tint(.white)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("1:24")
                            Spacer()
                            Text("3:45")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                    }
                    
                    // Controls
                    HStack(spacing: 60) {
                        Button {//TODO: Will have to implemement song reset once we can manage the songs time.
                            playPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Button {
                            togglePlay()
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .shadow(radius: 8)
                        }
                        
                        Button {
                            playNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    //Animated section
    private func movingSongContent(for song: Song) -> some View {
        VStack(spacing: 40) {
            // Album art
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 320, height: 320)
                    .shadow(color: .white.opacity(0.1), radius: 15)
            }
            
            // Song title + artist
            VStack(spacing: 8) {
                Text(song.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text(song.artist)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    private func playNext() { // Added by Tyler
        transitionDirection = .bottom
        
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false;
        withAnimation {
            if currentIndex < songs.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
        playSong(songs[currentIndex])
    }
    
    private func togglePlay() {// ==
        let song = songs[currentIndex]
        
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }
    
    private func playSong(_ song: Song) {// ==
            guard let fileName = song.fileName,
                  let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                            Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
                //print("⚠️ Audio file for \(song.title) not found.") --LINK TO ERROR
                isPlaying.toggle()//Despite there being no file, for test purposes keep this.
                return
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Audio playback error: \(error.localizedDescription)")
                isPlaying.toggle()//And this!
            }
        }
    
    private func playPrevious() { // Added by Tyler
        transitionDirection = .top
        
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false;
        withAnimation {
            if currentIndex > 0 {
                currentIndex -= 1
            } else {
                currentIndex = songs.count - 1
            }
            isPlaying = true
        }
    }
}

#Preview {
    NowPlayingView(mood: DummyData.moods.first!, startSong: DummyData.songs[2])
}
