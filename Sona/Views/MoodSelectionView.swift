//
//  MoodSelectionView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct MoodSelectionView: View {
    let moods = DummyData.moods
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
                        ForEach(moods) { mood in
                            NavigationLink(destination: SongPlaylistByMoodView(mood: mood)) {
                                
                                VStack(spacing: 8) {
                                    Text(mood.emoji)
                                        .font(.system(size: 37))
                                    Text(mood.name)
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                    //NOT SURE ABOUT INCLUDING THE DESC
//                                    if let desc = mood.description {
//                                        Text(desc)
//                                            .font(.footnote)
//                                            .foregroundColor(.white.opacity(0.7))
//                                            .multilineTextAlignment(.center)
//                                            .frame(height: 35)
//                                    }
                                }
                                .padding(15)
                                .frame(maxWidth: 170, minHeight: 105)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(mood.colorName))
                                )
                            }
                            .buttonStyle(.plain)
                        }
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
                        .font(.title)
                }
            }
        }
    }
}

#Preview {
    MoodSelectionView()
}
