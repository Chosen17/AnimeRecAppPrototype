//
//  Item.swift
//  AnimeRecommendationTinder-Mobile project
//
//  Created by EJ Rose on 04/04/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
