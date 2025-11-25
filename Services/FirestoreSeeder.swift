//
//  FirestoreSeeder.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-15.
//

// Fixed ID so songs can now match the correct album; we get moods from the Firestore, as well as albums, and songs per new user. (2025-11-15)

import FirebaseFirestore
import Foundation
import FirebaseAuth

struct FirestoreSeeder {
    static func seedUserData(for uid: String) {
        let db = Firestore.firestore()
        
        // Moods
        let moods: [Mood] = [
            Mood(id: "1", name: "Happy", emoji: "😄", description: "Upbeat songs", colorName: "happyColor"),
            Mood(id: "2", name: "Sleep", emoji: "🌙", description: "Relax vibes", colorName: "sleepColor"),
            Mood(id: "3", name: "Fit", emoji: "💪", description: "Workout", colorName: "fitColor"),
            Mood(id: "4", name: "Calm", emoji: "😌", description: "Chill", colorName: "calmColor")
        ]
        
        for mood in moods {
            do {
                try db.collection("users").document(uid)
                    .collection("moods").document(mood.id!)
                    .setData(from: mood)
            } catch {
                print("Error seeding mood:", error)
            }
        }
        
        // Albums
        let albums: [Album] = [
            Album(id: "1", name: "Minecraft Soundtrack", artist: "Aaron Cherof & Minecraft",
                  coverURL: "https://i.scdn.co/image/ab67616d0000b2732ed5db5c6b5a91746cc79e39", songIDs: ["5"]),
            Album(id: "2", name: "Sleepless - Single", artist: "AVAION",
                  coverURL: "https://i.scdn.co/image/ab67616d0000b273158cb15611f81555ebf97db6", songIDs: ["4"])
        ]
        
        for album in albums {
            do {
                try db.collection("users").document(uid)
                    .collection("albums").document(album.id!)
                    .setData(from: album)
            } catch {
                print("Error seeding album:", error)
            }
        }
        
        // Songs
        let songs: [Song] = [
            Song(id: "4", title: "Sleepless", artist: "AVAION", albumID: "2", moodID: "4", fileName: "Sleepless"),
            Song(id: "5", title: "Puzzlebox", artist: "Aaron", albumID: "1", moodID: "4", fileName: "Puzzlebox")
        ]
        
        for song in songs {
            do {
                try db.collection("users").document(uid)
                    .collection("songs").document(song.id!)
                    .setData(from: song)
            } catch {
                print("Error seeding song:", error)
            }
        }
    }
}
