//
//  ProfileView.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @State private var newName = ""
    @State private var errorMessage: String?
    @StateObject private var auth = AuthService.shared

    var body: some View {
        Form {
            Section("Profile") {
                Text("Email: \(auth.currentUser?.email ?? "-")")
                Text("Display Name: \(auth.currentUser?.displayName ?? "-")")
                Text("Is Active: \(auth.currentUser?.isActive == true ? "Yes" : "False")")
            }

            Section("Update Display Name") {
                TextField("New Display Name", text: $newName)

                Button("Save") {
                    guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
                        self.errorMessage = "Display name cannot be empty"
                        return
                    }

                    auth.updateProfile(displayName: newName) { result in
                        switch result {
                        case .success:
                            self.errorMessage = nil
                        case .failure(let failure):
                            self.errorMessage = failure.localizedDescription
                        }
                    }
                }
                .disabled(newName.isEmpty)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button(role: .destructive) {
                let result = auth.signOut()
                if case .failure(let failure) = result {
                    self.errorMessage = failure.localizedDescription
                } else {
                    self.errorMessage = nil
                }
            } label: {
                Text("Sign Out")
            }
        }
    }
}

#Preview {
    ProfileView()
}
