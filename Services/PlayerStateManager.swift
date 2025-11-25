//
//  PlayerStateManager.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-19.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

@MainActor
class PlayerStateManager: ObservableObject {
    static let shared = PlayerStateManager()
    
    @Published var currentSong: Song?
    @Published var currentAlbum: Album?
    @Published var isPlaying: Bool = false
    @Published var currentMood: Mood?
    @Published var isNowPlayingViewActive: Bool = false
    @Published var currentSongList: [Song] = []
    @Published var progress: Double = 0.0
    
    //This will ensure that the audio persists across views
    var audioPlayer: AVAudioPlayer?
    private var audioTimer: Timer?
    private let audioDelegate = AudioDelegate()
    
    private init() {
        // Set up audio delegate
        audioDelegate.onFinish = { [weak self] in
            self?.playNext()
        }
    }
    
    
    
    func playSong(_ song: Song, mood: Mood, album: Album? = nil, songList: [Song] = []) {
        self.currentSong = song
        self.currentMood = mood
        self.currentAlbum = album
        self.currentSongList = songList.isEmpty ? [song] : songList
        loadAndPlayAudio(song: song)
        self.isPlaying = true
    }
    
    func pause() {
        audioPlayer?.pause()
        stopProgressTimer()
        self.isPlaying = false
    }
    
    func play() {
        audioPlayer?.play()
        startProgressTimer()
        self.isPlaying = true
    }
    
    func stop() {
        audioPlayer?.stop()
        stopProgressTimer()
        self.currentSong = nil
        self.currentMood = nil
        self.currentAlbum = nil
        self.isPlaying = false
        self.progress = 0.0
    }
    
    func playNext() {
        guard let currentSong = currentSong,
              let currentIndex = currentSongList.firstIndex(where: { $0.id == currentSong.id }) else { return }
        
        let nextIndex = (currentIndex + 1) % currentSongList.count
        let nextSong = currentSongList[nextIndex]
        
        self.currentSong = nextSong
        loadAndPlayAudio(song: nextSong)
        self.isPlaying = true
    }
    
    func playPrevious() {
            guard let currentSong = currentSong,
                  let currentIndex = currentSongList.firstIndex(where: { $0.id == currentSong.id }) else { return }
            
            let previousIndex = (currentIndex - 1 + currentSongList.count) % currentSongList.count
            let previousSong = currentSongList[previousIndex]
            
            self.currentSong = previousSong
            loadAndPlayAudio(song: previousSong)
            self.isPlaying = true
        }
    
    private func loadAndPlayAudio(song: Song) {
        guard let fileName = song.fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
            print("❌ Audio file not found: \(song.fileName ?? "unknown")")
            return
        }

        do {
            audioPlayer?.stop()
            stopProgressTimer()
            
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            player.delegate = audioDelegate
            player.prepareToPlay()
            player.play()
            
            startProgressTimer()
            
        } catch {
            print("❌ Audio playback error: \(error.localizedDescription)")
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer,
                  player.duration > 0 else {
                return
            }
            self.progress = player.currentTime / player.duration
        }
    }
    
    private func stopProgressTimer() {
        audioTimer?.invalidate()
        audioTimer = nil
    }
    
    func showNowPlayingView() {
        self.isNowPlayingViewActive = true
    }
    
    func hideNowPlayingView() {
        self.isNowPlayingViewActive = false
    }
}

