//
//  LoginView.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var auth = AuthService.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section("Login") {
                TextField("Enter Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                SecureField("Password (Min 6 chars)", text: $password)

                }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Login") {
                print("Login clicked")

                guard Validators.isEmailValid(email) else {
                    self.errorMessage = "Invalid Email"
                    return
                }

                guard Validators.isValidPassword(password) else {
                    self.errorMessage = "Invalid Password"
                    return
                }
                
                auth.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        self.errorMessage = nil
                    case .failure(let failure):
                        self.errorMessage = failure.localizedDescription
                    }
                }

            }
            .disabled(email.isEmpty || password.isEmpty)
        }
    }
}

#Preview {
    LoginView()
}
