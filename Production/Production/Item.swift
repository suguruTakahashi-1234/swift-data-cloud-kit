//
//  Item.swift
//  Production
//
//  Created by Suguru Takahashi on 2025/04/11.
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
