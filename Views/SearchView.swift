//
//  SearchView.swift
//  Sona
//
//  Created by user285578 (Tyler) on 11/11/25.
//

import SwiftUI
import UIKit

struct SearchView: View {
    // MARK: - Data
    private let songs = DummyData.songs
    private let moods = DummyData.moods
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var searchMode: SearchMode = .songs
    @State private var filteredSongs: [Song] = []
    @State private var filteredMoods: [Mood] = []
    
    // MARK: - Segmented Control Styling (UIKit Appearance)
    init() {
        let appearance = UISegmentedControl.appearance()
        
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        appearance.selectedSegmentTintColor = UIColor.systemPurple
        
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
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
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // --- CUSTOM STYLED SEARCH BAR ---
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search \(searchMode.rawValue)...", text: $searchText)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: searchText) { _ in
                        performSearch()
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.purple.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // --- RESULTS (Only show if text entered) ---
            if !searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        
                        if searchMode == .songs {
                            ForEach(filteredSongs.prefix(2), id: \.id) { song in
                                NavigationLink(
                                    destination: NowPlayingView(
                                        mood: moodFor(song),
                                        startSong: song
                                    )
                                ) {
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
                                NavigationLink(
                                    destination: NowPlayingView(
                                        mood: mood,
                                        startSong: songsForMood(mood).first
                                    )
                                ) {
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
            filteredSongs = songs.filter {
                $0.title.hasPrefix(searchText) || $0.artist.hasPrefix(searchText)
            }
        case .moods:
            filteredMoods = moods.filter {
                $0.name.hasPrefix(searchText)
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
    NavigationStack { SearchView() }
}
