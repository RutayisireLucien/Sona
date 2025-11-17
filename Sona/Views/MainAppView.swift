//
//  MainAppView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct MainAppView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                MoodSelectionView()
                    .tabItem {
                        Label("Sona", systemImage: "waveform")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
            .tint(.pink)//Made it pink cuz it looks more poppish
        }
    }
}

#Preview {
    MainAppView()
}
