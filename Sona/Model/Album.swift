//
//  Album.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-13.
//

import Foundation
import FirebaseFirestore

struct Album: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var artist: String
    var coverURL: String? // album art added by Alvaro
    var songIDs: [String] = [] // reference songs in this album
}
