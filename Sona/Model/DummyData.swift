//
//  DummyData.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation

struct DummyData {
    static let moods: [Mood] = [
        Mood(id: "1", name: "Happy", emoji: "😄", description: "Upbeat songs to boost your mood", colorName: "happyColor"),
        Mood(id: "2", name: "Sleep", emoji: "🌙", description: "Relax and unwind vibes", colorName: "sleepColor"),
        Mood(id: "3", name: "Fit", emoji: "💪", description: "Get pumped and focused", colorName: "fitColor")
    ]
    
    static let songs: [Song] = [
        Song(id: "1", title: "Sunshine", artist: "Nova", moodID: "1"),
        Song(id: "2", title: "Good Energy", artist: "Rheia", moodID: "1"),
        Song(id: "3", title: "Late Nights", artist: "Céline", moodID: "2"),
        Song(id: "4", title: "Blue Hour", artist: "Aiden", moodID: "2"),
        Song(id: "5", title: "Focus Up", artist: "Kai", moodID: "3"),
        Song(id: "6", title: "Run the Day", artist: "Vero", moodID: "3")
    ]
}
