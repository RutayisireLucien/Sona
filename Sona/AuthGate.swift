//
//  AuthGate.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct AuthGate: View {
    @State private var showLogin = true

    var body: some View {
        VStack {
            Picker("", selection: $showLogin) {
                Text("Login").tag(true)
                Text("Register").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if showLogin {
                LoginView()
            } else {
                RegisterView()
            }
        }
    }
}

#Preview {
    AuthGate()
}
