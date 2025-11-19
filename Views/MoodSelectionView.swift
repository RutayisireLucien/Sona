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
                    VStack(spacing: 20) {
                        
                        // --- MOOD GRID ---
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(moods) { mood in
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
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(mood.colorName))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        // --- SEARCH VIEW UNDER MOODS ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Search Songs & Moods")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            SearchView()
                                .padding(.horizontal)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
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
    }
}


#Preview {
    MoodSelectionView()
}
