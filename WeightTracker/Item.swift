//
//  Item.swift
//  WeightTracker
//
//  Created by Erik Olsen on 23/05/2026.
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
