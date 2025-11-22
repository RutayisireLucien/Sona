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
    @State private var transitionDirection: Edge = .top // for up/down animation (Differing from spotify and apple on purpose, cuz we're better.)
    @State private var audioPlayer: AVAudioPlayer?
    @StateObject private var audioManager = AudioManager()
    @State private var contextDelegate = AudioDelegate()
    @State private var isShuffling = false
    @State private var shuffleOrder: [Int] = []
    @State private var shufflePosition: Int = 0

    
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
        let _song = songs[currentIndex]//If theres a warning, Ignore, its used for the animation function.
        
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
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                toggleShuffle()
                            }
                        } label: {
                            Image(systemName: isShuffling ? "shuffle.circle.fill" : "shuffle")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 5)
                        }
                        .padding(.leading)
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
                        ProgressView(value: audioManager.progress)
                            .progressViewStyle(.linear)
                            .tint(.white)
                            .padding(.horizontal)
                        
                        HStack {
                            Text(audioManager.formatTime(audioPlayer?.currentTime ?? 0))
                            Spacer()
                            Text(audioManager.formatTime(audioPlayer?.duration ?? 0))
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
        audioManager.stopTimer()
        audioPlayer?.stop()
        isPlaying = false;
        
        withAnimation {
            //Shuffle code
            if isShuffling {
                shufflePosition += 1
                
                if shufflePosition >= shuffleOrder.count {
                    shufflePosition = 0
                }
                
                currentIndex = shuffleOrder[shufflePosition]
                
            } else {//Regular playNext() code
                if currentIndex < songs.count - 1 {
                    currentIndex += 1
                } else {
                    currentIndex = 0
                }
            }
        }
        playSong(songs[currentIndex])
    }
    
    private func togglePlay() {// ==
        let song = songs[currentIndex]
        
        if let player = audioPlayer {
            if isPlaying {
                player.pause()
                isPlaying = false
                audioManager.stopTimer()
            }else {
                player.play()
                audioManager.startTimer(for: player)
                isPlaying = true
            }
        } else {
            playSong(song)
        }
    }
    
    private func playSong(_ song: Song) {
        guard let fileName = song.fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: fileName, withExtension: "m4a") else {

            // File missing → fallback UI behavior
            audioPlayer = nil
            audioManager.progress = 0.5
            isPlaying.toggle()
            return
        }

        do {
            // Create player only once
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player

            player.delegate = contextDelegate
            
            //Auto-skip
            contextDelegate.onFinish = { [self] in
                self.audioManager.stopTimer()

                withAnimation(.easeInOut(duration: 0.5)) {
                    self.transitionDirection = .bottom
                    self.playNext()
                }
            }

            // Prepare & play
            player.prepareToPlay()
            player.play()
            isPlaying = true

            // Start updating progress
            audioManager.startTimer(for: player)

        } catch {
            print("Audio playback error: \(error.localizedDescription)")
            audioManager.progress = 0.0
            isPlaying.toggle()
        }
    }

    
    private func playPrevious() { // ==
        transitionDirection = .top
        audioManager.stopTimer()
        audioPlayer?.stop()
        isPlaying = false;
        withAnimation {
            
            if isShuffling {
                shufflePosition -= 1
                
                if shufflePosition < 0 {
                    shufflePosition = shuffleOrder.count - 1
                }
                
                currentIndex = shuffleOrder[shufflePosition]
            } else {
                if currentIndex > 0 {
                    currentIndex -= 1
                } else {
                    currentIndex = songs.count - 1
                }
                isPlaying = true
            }
        }
        playSong(songs[currentIndex])
    }
    
    //shuffle commands:
    
    private func toggleShuffle() {
        isShuffling.toggle()
        
        if isShuffling {
            let indeces = Array(0..<songs.count).filter { $0 != currentIndex }
            shuffleOrder = indeces.shuffled()
            
            
            shuffleOrder.insert(currentIndex, at: 0)
            shufflePosition = 0
        }
        else {
            shuffleOrder = []
            shufflePosition = 0
        }
    }
}

#Preview {
    NowPlayingView(mood: DummyData.moods[4], startSong: DummyData.songs[6])//Can put the indexes wherever. Leave on puzzlebox for music.
}
