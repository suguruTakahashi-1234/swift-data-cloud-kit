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
    var id: UUID = UUID()
    var order: Int = -Int.max
    var text: String = ""
    var timestamp: Date = Date.now

    init(text: String, timestamp: Date) {
        self.id = UUID()
        self.text = text
        self.timestamp = timestamp
    }
}
