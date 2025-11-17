//
//  MiniPlayerBar.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-14.
//
// Bottom bar finished to display current playing track (not properly implemented yet). (2025-11-15)

import SwiftUI

struct MiniPlayerBar: View {
    let song: Song
    let album: Album?
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onExpand: () -> Void
    
    var body: some View {
        Button(action: onExpand) {
            HStack(spacing: 12) {
                
                albumArt
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    onPlayPause()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
    
    private var albumArt: some View {
        ZStack {
            if let urlString = album?.coverURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { img in
                    img.resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.white.opacity(0.1)
                }
            } else {
                Color.white.opacity(0.1)
            }
        }
        .frame(width: 45, height: 45)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    MiniPlayerBar(
        song: Song(id: "7", title: "Puzzlebox", artist: "Aaron", albumID: "1", moodID: "4", fileName: "Puzzlebox"),
        album: Album(id: "1", name: "Sona", artist: "Aaron", coverURL: "https://i.scdn.co/image/ab67616d0000b2732ed5db5c6b5a91746cc79e39",songIDs: ["7"]),
        isPlaying: true,
        onPlayPause: {},
        onExpand: {}
    )
}
