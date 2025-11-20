//
//  SearchView.swift
//  Sona
//
//  Created by Tyler Pistilli on 2025-11-07.
//

import SwiftUI
import UIKit

struct SearchView: View {
    @StateObject private var songService = SongService.shared
    @StateObject private var moodService = MoodService.shared
    
    @State private var searchText: String = ""
    @State private var searchMode: SearchMode = .songs
    @State private var filteredSongs: [Song] = []
    @State private var filteredMoods: [Mood] = []
    
    // From w3School code, needed to change the picker color.
    init() {
        let appearance = UISegmentedControl.appearance()
                
        // Background of the whole control
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.40)
        
        // Color of the selected segment "pill"
        appearance.selectedSegmentTintColor = UIColor.systemPurple
        
        // Text color: normal (unselected)
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
        
        // Text color: selected
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // --- SEARCH MODE PICKER ---
            Picker("Search Type", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // --- SEARCH ---
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search \(searchMode.rawValue)...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: searchText) { _ in
                        performSearch()
                    }
                    .foregroundColor(Color.white)
            }
            .background(RoundedRectangle(cornerRadius: 18)
                .fill(Color.purple.opacity(0.15))
            )
            .padding(.horizontal)
            
            // --- RESULTS (Only show if text entered) ---
            if !searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        if searchMode == .songs {
                            ForEach(filteredSongs.prefix(2), id: \.id) { song in
                                NavigationLink(destination: NowPlayingView(mood: moodFor(song), startSong: song, songs: songService.allSongs))
                                    {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(song.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(song.artist)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.purple.opacity(0.25))
                                    )
                                }
                            }
                        } else {
                            ForEach(filteredMoods.prefix(2), id: \.id) { mood in
                                NavigationLink(destination: NowPlayingView(mood: mood, startSong: songsForMood(mood).first, songs: songsForMood(mood)))
                                    {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(mood.name)
                                                .font(.headline)
                                                .foregroundColor(Color(mood.colorName))
                                            Text("Mood Playlist")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.purple.opacity(0.25))
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 160)
            }
        }
        .onAppear {
            // Start listening for user data
            moodService.listenToUserMoods()
        }
        .onDisappear {
            moodService.stopListening()
        }
    }
    
    // search bar function thing
    private func performSearch() {
        guard !searchText.isEmpty else {
            filteredSongs.removeAll()
            filteredMoods.removeAll()
            return
        }
        
        let searchLower = searchText.lowercased()
        
        switch searchMode {
        case .songs:
            filteredSongs = songService.allSongs.filter { song in
                song.title.lowercased().hasPrefix(searchLower) ||
                song.artist.lowercased().hasPrefix(searchLower)
            }
        case .moods:
            filteredMoods = moodService.userMoods.filter { mood in
                mood.name.lowercased().hasPrefix(searchLower)
            }
        }
    }
    
    // helper
    private func moodFor(_ song: Song) -> Mood {
        moodService.userMoods.first(where: { $0.id == song.moodID }) ?? moodService.userMoods.first ?? Mood(id: "default", name: "Default", emoji: "🎵", colorName: "purple")
    }
    
    private func songsForMood(_ mood: Mood) -> [Song] {
        songService.allSongs.filter { $0.moodID == mood.id }
    }
}

// Search enum
enum SearchMode: String, CaseIterable {
    case songs
    case moods
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
