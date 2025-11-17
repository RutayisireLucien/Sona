//
// NowPlayingView.swift
// Sona
//
// Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// Play selected, songs, updates album cover on song chagne, fetches data from Firestore not hardcored data (DummyData) (2025-11-15)

import UIKit
import SwiftUI
import AVFoundation
import FirebaseAuth
import Firebase

struct NowPlayingView: View {

    // Album data fetched from Firestore
    @State private var album: Album? //Added by Alvaro

    @State var songs: [Song]
    @ObservedObject private var songService = SongService.shared
    let mood: Mood
    let startSong: Song?

    @State private var currentIndex: Int = 0
    @State private var isPlaying = false
    @State private var isFavourite = false
    @State private var progress: Double = 0.0
    @State private var transitionDirection: Edge = .top // for up/down animation (Differing from spotify and apple on purpose.)
    @State private var audioPlayer: AVAudioPlayer?

    init(mood: Mood, startSong: Song? = nil, songs: [Song]) {
        self.mood = mood
        self.startSong = startSong
        _songs = State(initialValue: songs)

        if let startSong = startSong,
           let index = songs.firstIndex(where: { $0.id == startSong.id }) {
            _currentIndex = State(initialValue: index)
        } else {
            _currentIndex = State(initialValue: 0)
        }
    }

    var body: some View {
        let song = songs[currentIndex] //Ignore the warning, its used for the animation function.

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

            VStack(spacing: 40) {
                ZStack {
                    ForEach(Array(songs.enumerated()), id: \.offset) { idx, s in
                        if idx == currentIndex {
                            movingSongContent(for: s)
                                .transition(.move(edge: transitionDirection)
                                    .combined(with: .opacity))
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)

                // COntent that stays in place (Controls + Heart + Progress)
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                isFavourite.toggle()
                            }
                        } label: {
                            Image(systemName: isFavourite ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(isFavourite ? .red : .white)
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

                    // Buttons
                    HStack(spacing: 60) { //TODO: Will have to implemement song reset once we can manage the songs time.
                        Button { playPrevious() } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Button { togglePlay() } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                        }

                        Button { playNext() } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }

        // Load album on appear
        .onAppear {
            fetchAlbumSong()
        }

        // onChange will ensure that the correct album cover is displayed each time the song is changed. (We can ignore the warning). (We won't have to write fetchAlbum() every single time)
        .onChange(of: currentIndex) { _ in
            fetchAlbumSong()
        }
    }

    //Animated section
    private func movingSongContent(for song: Song) -> some View {
        VStack(spacing: 40) {
            ZStack {
                //Added by Alvaro
                // Get album URL
                if let urlString = album?.coverURL,
                   let url = URL(string: urlString) {

                    AsyncImage(url: url) { img in
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 320, height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 320, height: 320)
                            .redacted(reason: .placeholder)
                    }

                } else {
                    // no album cover
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 320, height: 320)
                }
            }

            // Song (title + artist)
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
        isPlaying = false
        withAnimation {
            if currentIndex < songs.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
        playSong(songs[currentIndex])
    }
    
    private func togglePlay() {
        let song = songs[currentIndex]

        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            playSong(song)
        }
    }

    private func playSong(_ song: Song) {
        guard let fileName = song.fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: fileName, withExtension: "m4a")
        else {
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
        isPlaying = false

        withAnimation {
            if currentIndex > 0 {
                currentIndex -= 1
            } else {
                currentIndex = songs.count - 1
            }
            isPlaying = true
        }
        playSong(songs[currentIndex])
    }

    // Added by Alvaro
    private func fetchAlbumSong() {
        guard let albumID = songs[currentIndex].albumID else {
            print("❌ No albumID in song: \(songs[currentIndex].title)")
            return
        }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }

        let ref = Firestore.firestore()
            .collection("users").document(userID)
            .collection("albums").document(albumID)

        ref.getDocument { snap, error in
            if let error = error {
                print("❌ Firestore error: \(error)")
                return
            }

            guard let snap = snap, snap.exists else {
                print("❌ Album \(albumID) does not exist for user \(userID)")
                return
            }

            do {
                let album = try snap.data(as: Album.self)
                self.album = album
                print("✅ Album loaded:", album.name)
            } catch {
                print("❌ Album decoding error:", error)
            }
        }
    }
}
