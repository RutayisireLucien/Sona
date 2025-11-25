//
//  AudioManager.swift
//  Sona
//
//  Created by user285578 on 11/11/25.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    @Published var progress: Double = 0.0
    
    private var timer: Timer?
    
    func startTimer(for player: AVAudioPlayer?) {
        stopTimer() //prevents duplication of timers
        
        guard let player = player else {
            progress = 0.0
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self , player.duration > 0
            else {
                return
            }
            self.progress = player.currentTime / player.duration
        }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds > 0
                else {
                    return "0:00"
                }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String (format: "%d:%02d", mins, secs)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
