//
//  Item.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
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
