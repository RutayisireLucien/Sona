//
//  SearchView.swift
//  Sona
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
    
    // MARK: - Segmented Control Styling
    init() {
        let appearance = UISegmentedControl.appearance()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        appearance.selectedSegmentTintColor = UIColor.systemPurple
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            // Search mode picker
            Picker("Search Type", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Search bar
            SearchBar(
                searchText: $searchText,
                placeholder: "Search \(searchMode.rawValue)...",
                onChange: performSearch
            )
            .padding(.horizontal)
            
            // Results
            if !searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        if searchMode == .songs {
                            SongResultsList(
                                songs: filteredSongs,
                                moodFor: moodFor
                            )
                        } else {
                            MoodResultsList(
                                moods: filteredMoods,
                                songsForMood: songsForMood
                            )
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
    
    private func moodFor(_ song: Song) -> Mood {
        moods.first(where: { $0.id == song.moodID }) ?? moods.first!
    }
    
    private func songsForMood(_ mood: Mood) -> [Song] {
        songs.filter { $0.moodID == mood.id }
    }
}


// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    let onChange: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField(placeholder, text: $searchText)
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _ in onChange() }
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
    }
}


// MARK: - Song Results Component
struct SongResultsList: View {
    let songs: [Song]
    let moodFor: (Song) -> Mood
    
    var body: some View {
        ForEach(songs.prefix(2), id: \.id) { song in
            NavigationLink(
                destination: NowPlayingView(
                    mood: moodFor(song),
                    startSong: song,               // correct fix
                    songs: songs                    // pass list
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
    }
}


// MARK: - Mood Results Component
struct MoodResultsList: View {
    let moods: [Mood]
    let songsForMood: (Mood) -> [Song]
    
    var body: some View {
        ForEach(moods.prefix(2), id: \.id) { mood in
            NavigationLink(
                destination: NowPlayingView(
                    mood: mood,
                    startSong: songsForMood(mood).first,
                    songs: songsForMood(mood)
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


enum SearchMode: String, CaseIterable {
    case songs
    case moods
}


// Preview
#Preview {
    NavigationStack { SearchView() }
}
