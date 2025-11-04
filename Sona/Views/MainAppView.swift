//
//  MainAppView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            MoodSelectionView()
                .tabItem {
                    Label("Moods", systemImage: "waveform")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(.purple)
    }
}

#Preview {
    MainAppView()
}
