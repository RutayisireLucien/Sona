//
//  MoodSelectionView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// Displays now only logged user-specific moods fetched live from Firestore. (2025-11-15)
// Create mood and delete implemented (2025-11-20)

import SwiftUI

struct MoodSelectionView: View {
    @StateObject private var moodService = MoodService.shared
    @State private var showingAddMood = false
    @State private var showDeleteAlert = false
    @State private var moodToDelete: Mood?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background colour
                LinearGradient(
                    colors: [
                        Color(red: 0.11, green: 0.00, blue: 0.15),
                        Color(red: 0.24, green: 0.00, blue: 0.46)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(moodService.userMoods) { mood in
                            NavigationLink(destination: SongPlaylistByMoodView(mood: mood)) {
                                moodCard(mood) // by Alvaro
                                //I removed this as one function to simplyfy and get chosen colour
                                //                                VStack(spacing: 8) {
                                //                                    Text(mood.emoji)
                                //                                        .font(.system(size: 37))
                                //                                    Text(mood.name)
                                //                                        .font(.title3.bold())
                                //                                        .foregroundColor(.white)
                                //                                }
                                //                                .padding(15)
                                //                                .frame(maxWidth: 170, minHeight: 105)
                                //                                .background(
                                //                                    RoundedRectangle(cornerRadius: 20)
                                //                                        .fill(Color(mood.colorName))
                                //                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        //Add mood rectangle
                        Button {
                            showingAddMood = true
                        } label: {
                            addMoodCard
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            //We use toolbar to be able to change the title style
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Your Mood 🎧")
                        .padding(.top, 60)
                        .foregroundColor(.white)
                        .font(.title.bold())
                }
            }
        }
        .sheet(isPresented: $showingAddMood) {
            AddMoodView()
        }
        .onAppear {
            moodService.listenToUserMoods()
        }
        .onDisappear {
            moodService.stopListening()
        }
        .alert("Delete Mood", isPresented: $showDeleteAlert, presenting: moodToDelete) { mood in
            Button("Cancel", role: .cancel) {
                moodToDelete = nil
            }
            Button("Delete", role: .destructive) {
                confirmDelete()
            }
        } message: { mood in
            Text("Are you sure you want to delete \"\(mood.name)\"? This will also remove all songs associated with this mood.")
        }
    }
    
    //Added by Alvaro
    private func moodCard(_ mood: Mood) -> some View {
        VStack(spacing: 8) {
            Text(mood.emoji)
                .font(.system(size: 37))
            Text(mood.name)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding(15)
        .frame(maxWidth: 170, minHeight: 105)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(mood.colorName))
        )
        .contextMenu {
            Button(role: .destructive) {
                deleteMood(mood)
            } label: {
                Label("Delete Mood", systemImage: "trash")
            }
        }
    }
    
    //added by Alvaro
    private var addMoodCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 37))
                .foregroundColor(.white.opacity(0.7))
            Text("Add Mood")
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(15)
        .frame(maxWidth: 170, minHeight: 105)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    //Adde by Alvaro
    private func deleteMood(_ mood: Mood) {
        moodToDelete = mood
        showDeleteAlert = true
    }
    
    //Added by alvaro
    private func confirmDelete() {
        guard let mood = moodToDelete, let moodId = mood.id else { return }
        
        moodService.deleteMood(moodId) { result in
            switch result {
            case .success:
                print("Mood deleted successfully")
            case .failure(let error):
                print("Error deleting mood: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MoodSelectionView()
}
