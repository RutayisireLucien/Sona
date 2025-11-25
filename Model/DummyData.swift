//
//  DummyData.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation

@MainActor
struct DummyData {
    static let moods: [Mood] = [
        Mood(id: "1", name: "Happy", emoji: "😄", description: "Upbeat songs to boost your mood", colorName: "happyColor"),
        Mood(id: "2", name: "Sleep", emoji: "🌙", description: "Relax and unwind vibes", colorName: "sleepColor"),
        Mood(id: "3", name: "Fit", emoji: "💪", description: "Get pumped and focused", colorName: "fitColor"),
        Mood(id: "4", name: "Calm", emoji: "😄", description: "Calm state of mind", colorName: "fitColor"),
        Mood(id: "5", name: "None", emoji: "🌙", description: "No specific Mood", colorName: "noneColor")
    ]
    
    static let songs: [Song] = [
        Song(id: "1", title: "Sunshine", artist: "Nova", moodID: "1", fileName: "LL"),
        Song(id: "2", title: "Good Energy", artist: "Rheia", moodID: "1", fileName: "LL"),
        Song(id: "3", title: "Late Nights", artist: "Céline", moodID: "2", fileName: "LL"),
        Song(id: "4", title: "Blue Hour", artist: "Aiden", moodID: "2", fileName: "LL"),
        Song(id: "5", title: "Focus Up", artist: "Kai", moodID: "3", fileName: "LL"),
        Song(id: "6", title: "Run the Day", artist: "Vero", moodID: "3", fileName: "LL"),
        Song(id: "7", title: "Puzzlebox", artist: "Aaron", moodID: "4", fileName: "Puzzlebox")
    ]
}
