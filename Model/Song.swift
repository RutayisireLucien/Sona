//
//  Song.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation
import FirebaseFirestore

struct Song: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var artist: String
    var album: String?
    var moodID: String
    let fileName: String?
}
