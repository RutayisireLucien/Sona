//
//  Song.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation
import FirebaseFirestore

struct Song: Identifiable, Codable, @unchecked Sendable {
    @DocumentID var id: String?
    var title: String
    var artist: String
    var albumID: String?
    var moodID: String
    let fileName: String?
}
