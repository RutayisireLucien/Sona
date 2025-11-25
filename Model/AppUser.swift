//
//  AppUser.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable, @unchecked Sendable {
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var isActive: Bool = true
}
