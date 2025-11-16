//
//  SearchView.swift
//  Sona
//
//  Created by user285578 (Tyler) on 11/11/25.
//

import SwiftUI

//
//  SearchView.swift
//  Sona
//
//  Created by Tyler Pistilli on 2025-11-07.
//

import SwiftUI

struct SearchView: View {
    // MARK: - Data
    private let songs = DummyData.songs
    private let moods = DummyData.moods
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var searchMode: SearchMode = .songs
    @State private var filteredSongs: [Song] = []
    @State private var filteredMoods: [Mood] = []
    
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
            
            // --- SEARCH FIELD ---
            TextField("Search \(searchMode.rawValue)...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: searchText) { _ in
                    performSearch()
                }
            
            // --- RESULTS (Only show if text entered) ---
            if !searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        if searchMode == .songs {
                            ForEach(filteredSongs.prefix(2), id: \.id) { song in
                                NavigationLink(destination: NowPlayingView(mood: moodFor(song), startSong: song)) {
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
                                            .fill(Color.black.opacity(0.25))
                                    )
                                }
                            }
                        } else {
                            ForEach(filteredMoods.prefix(2), id: \.id) { mood in
                                NavigationLink(destination: NowPlayingView(mood: mood, startSong: songsForMood(mood).first)) {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(mood.name)
                                                .font(.headline)
                                                .foregroundColor(Color(mood.colorName))
                                            Text("Color: \(mood.colorName)")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.black.opacity(0.25))
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
    }
    
    // MARK: - Search Logic
    private func performSearch() {
        guard !searchText.isEmpty else {
            filteredSongs.removeAll()
            filteredMoods.removeAll()
            return
        }
        
        switch searchMode {
        case .songs:
            filteredSongs = songs.filter { song in
                song.title.hasPrefix(searchText) || song.artist.hasPrefix(searchText)
            }
        case .moods:
            filteredMoods = moods.filter { mood in
                mood.name.hasPrefix(searchText)
            }
        }
    }
    
    // MARK: - Helpers
    private func moodFor(_ song: Song) -> Mood {
        moods.first(where: { $0.id == song.moodID }) ?? moods.first!
    }
    
    private func songsForMood(_ mood: Mood) -> [Song] {
        songs.filter { $0.moodID == mood.id }
    }
}

// MARK: - Search Mode Enum
enum SearchMode: String, CaseIterable {
    case songs
    case moods
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
