//
//  MoodSelectionView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// Displays now only logged user-specific moods fetched live from Firestore. (2025-11-15)

import SwiftUI

struct MoodSelectionView: View {
    @StateObject private var moodService = MoodService.shared
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.11, green: 0.00, blue: 0.15),
                             Color(red: 0.24, green: 0.00, blue: 0.46)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(moodService.userMoods) { mood in
                            NavigationLink(destination: SongPlaylistByMoodView(mood: mood)) {
                                VStack(spacing: 8) {
                                    Text(mood.emoji)
                                        .font(.system(size: 37))
                                    Text(mood.name)
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                }
                                .padding(15)
                                .frame(maxWidth: 170, minHeight: 105)
                                .background(RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(mood.colorName)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Your Mood 🎧")
                        .padding(.top, 60)
                        .foregroundColor(.white)
                        .font(.title.bold())
                }
            }
        }
        .onAppear {
            moodService.listenToUserMoods()
        }
        .onDisappear {
            moodService.stopListening()
        }
    }
}

#Preview {
    MoodSelectionView()
}
