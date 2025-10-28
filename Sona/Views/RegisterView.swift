//
//  RegisterView.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @StateObject private var auth = AuthService.shared
 
    var body: some View {
        Form {
            Section("Create Account") {
                TextField("Enter Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                SecureField("Password (Min 6 chars)", text: $password)

                TextField("Enter Display Name", text: $displayName)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Sign Up") {
                print("Sign up clicked")

                guard Validators.isEmailValid(email) else {
                    self.errorMessage = "Invalid Email"
                    return
                }

                guard Validators.isValidPassword(password) else {
                    self.errorMessage = "Invalid Password"
                    return
                }

                guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
                    self.errorMessage = "Display name is required"
                    return
                }

                auth.signUp(email: email, password: password, displayName: displayName) { result in
                    switch result {
                    case .success:
                        self.errorMessage = nil
                    case .failure(let failure):
                        self.errorMessage = failure.localizedDescription
                    }
                }
            }
            .disabled(email.isEmpty || password.isEmpty || displayName.isEmpty)
        }
    }
}

#Preview {
    RegisterView()
}
