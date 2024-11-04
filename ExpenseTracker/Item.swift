//
//  Item.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
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
