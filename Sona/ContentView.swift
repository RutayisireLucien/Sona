//
//  ContentView.swift
//  Sona
//
//  Created by user278698 on 10/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared
    @State private var isLoaded = false

    var body: some View {
        Group {
            if !isLoaded {
                ProgressView()
                    .onAppear {
                        auth.fetchCurrentAppUser { _ in
                            isLoaded = true
                        }
                    }
            } else if auth.currentUser == nil {
                // login
                //register screen switcher
                AuthGate()
            } else {
                MoodSelectionView()
            }
        }
    }
}


#Preview {
    ContentView()
}
