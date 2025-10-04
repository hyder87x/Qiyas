//
//  Item.swift
//  Qiyas
//
//  Created by Abdulla Hyder Mac23 on 04/10/2025.
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
