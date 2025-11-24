//
//  NowPlayingView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// Play selected songs, updates album cover on song change, fetches data from Firestore not hardcoded data (DummyData) (2025-11-15)
// Album model deleted, song cover will be shown instead (2025-11-23)

import SwiftUI
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

struct NowPlayingView: View {
    let songs: [Song]
    let mood: Mood
    let startSong: Song?
    
    @State private var currentIndex: Int = 0
    @State private var transitionDirection: Edge = .top // for up/down animation (Differing from spotify and apple on purpose, cuz we're better.)
    @State private var isShuffling = false
    @State private var shuffleOrder: [Int] = []
    @State private var shufflePosition: Int = 0
    //Without environment object the mini bar would not update what is happening in NowPlayingView (song cover, songs)
    @EnvironmentObject private var playerState: PlayerStateManager

    private var isFavourite: Bool {
            guard let currentSong = playerState.currentSong,
                  let song = songs.first(where: { $0.id == currentSong.id }) else {
                return false
            }
            return song.isFavourite
        }
    
    init(mood: Mood, startSong: Song? = nil, songs: [Song]) {
        self.mood = mood
        self.startSong = startSong
        self.songs = songs
        
        if let startSong = startSong,
           let index = songs.firstIndex(where: { $0.id == startSong.id }) {
            _currentIndex = State(initialValue: index)
        } else {
            _currentIndex = State(initialValue: 0)
        }
    }
    
    var body: some View {
        let currentSong = songs[currentIndex] // If there's a warning, Ignore, its used for the animation function.
        
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
            
            // Animated
            VStack(spacing: 40) {
                ZStack {
                    ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                        if index == currentIndex {
                            movingSongContent(for: song)
                                .transition(.move(edge: transitionDirection)
                                    .combined(with: .opacity))
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                
                // Content that stays in place
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
                            toggleFavourite()
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
                        ProgressView(value: playerState.progress)
                            .progressViewStyle(.linear)
                            .tint(.white)
                            .padding(.horizontal)
                        
                        HStack {
                            Text(formatTime(playerState.audioPlayer?.currentTime ?? 0))
                            Spacer()
                            Text(formatTime(playerState.audioPlayer?.duration ?? 0))
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                    }
                    
                    // Controls
                    HStack(spacing: 60) {
                        Button {
                            playPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Button {
                            togglePlay()
                        } label: {
                            Image(systemName: playerState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
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
        .onAppear {
            playerState.showNowPlayingView()
            
            // Update current index based on current song
            if let currentSong = playerState.currentSong,
               let index = songs.firstIndex(where: { $0.id == currentSong.id }) {
                currentIndex = index
            }
        }
        .onDisappear {
            playerState.hideNowPlayingView()
        }
        
        // Update current index when song changes externally (from PlayerStateManager)
        .onChange(of: playerState.currentSong?.id) { newSongID in
            if let newSongID = newSongID,
               let index = songs.firstIndex(where: { $0.id == newSongID }) {
                withAnimation {
                    currentIndex = index
                }
            }
        }
        
        // Update UI when shuffle changes
        .onChange(of: isShuffling) { _ in
            updateShuffleOrder()
        }
    }
    
    // Animated section
    private func movingSongContent(for song: Song) -> some View {
        VStack(spacing: 40) {
            ZStack {
                if let coverURLString = song.coverURL,
                   let url = URL(string: coverURLString) {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 320, height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 320, height: 320)
                            .overlay(
                                ProgressView()
                                    .foregroundColor(.white)
                            )
                    }
                    
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 320, height: 320)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
            }
            // song title + artist
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

    private func playNext() {
        transitionDirection = .bottom
        
        if isShuffling {
            shufflePosition += 1
            if shufflePosition >= shuffleOrder.count {
                shufflePosition = 0
            }
            let nextIndex = shuffleOrder[shufflePosition]
            playerState.currentSong = songs[nextIndex]
            playerState.play()
        } else {
            playerState.playNext()
        }
    }
    
    private func togglePlay() {
        if playerState.isPlaying {
            playerState.pause()
        } else {
            playerState.play()
        }
    }
    
    private func playPrevious() {
        transitionDirection = .top
        
        if isShuffling {
            shufflePosition -= 1
            if shufflePosition < 0 {
                shufflePosition = shuffleOrder.count - 1
            }
            let previousIndex = shuffleOrder[shufflePosition]
            playerState.currentSong = songs[previousIndex]
            playerState.play()
        } else {
            playerState.playPrevious()
        }
    }
    
    //This ensures that the mini player gets the time a song is paused and played
    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds > 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    // Shuffle commands:
    private func toggleShuffle() {
        isShuffling.toggle()
    }
    
    private func updateShuffleOrder() {
        if isShuffling {
            let indices = Array(0..<songs.count).filter { $0 != currentIndex }
            shuffleOrder = indices.shuffled()
            shuffleOrder.insert(currentIndex, at: 0)
            shufflePosition = 0
        } else {
            shuffleOrder = []
            shufflePosition = 0
        }
    }
    
    private func toggleFavourite() {
        guard let currentSong = playerState.currentSong,
              let songId = currentSong.id else { return }
        
        SongService.shared.toggleFavourite(songId: songId) { result in
            switch result {
            case .success:
                print("Favourite toggled in NowPlayingView: \(!isFavourite)")
                // The UI will update automatically because isFavourite is a computed property
            case .failure(let error):
                print("Error toggling favourite: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NowPlayingView(
        mood: Mood(id: "1", name: "Chill", emoji: "😌", colorName: "blue"),
        songs: [
            Song(id: "1", title: "Sample Song", artist: "Sample Artist", moodID: "1", audioData: "sample"),
            Song(id: "2", title: "Another Song", artist: "Another Artist", moodID: "1", audioData: "sample2")
        ]
    )
    .environmentObject(PlayerStateManager.shared)
}
