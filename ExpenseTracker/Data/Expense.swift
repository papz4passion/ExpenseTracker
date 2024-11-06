//
//  ExpenseCategory.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//


import SwiftData
import Foundation
import SwiftUICore

enum ExpenseCategory: String, Codable, CaseIterable, Comparable {
    static func < (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        return lhs == rhs
    }
    
    case food = "Food"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case bills = "Bills"
    case others = "Others"
    
    var color: Color {
        switch self {
        case .food: return .green
        case .transport: return .blue
        case .entertainment: return .purple
        case .bills: return .orange
        case .others: return .gray
        }
    }
}


enum RecurrenceInterval: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

enum KakeiboTag: String, Codable, CaseIterable {
    case needs = "Needs"
    case wants = "Wants"
    case culture = "Culture"
    case unexpected = "Unexpected"
}

enum ModeOfPayment: String, Codable, CaseIterable {
    case cash = "Cash"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case UPI = "UPI"
    case mobileApp = "MobileApp"
    case other = "Other"
}

@Model
final class Expense: Identifiable, Codable, ObservableObject {
    var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var recurrence: RecurrenceInterval
    var kakeiboTag: KakeiboTag
    var modeOfPayment: ModeOfPayment // New field added
    
    init(title: String, amount: Double, date: Date = Date(), category: ExpenseCategory, recurrence: RecurrenceInterval = .none, kakeiboTag: KakeiboTag, modeOfPayment: ModeOfPayment) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.recurrence = recurrence
        self.kakeiboTag = kakeiboTag
        self.modeOfPayment = modeOfPayment
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case amount
        case date
        case category
        case recurrence
        case kakeiboTag
        case modeOfPayment // Include in coding keys
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(category.rawValue, forKey: .category)
        try container.encode(recurrence.rawValue, forKey: .recurrence)
        try container.encode(kakeiboTag.rawValue, forKey: .kakeiboTag)
        try container.encode(modeOfPayment.rawValue, forKey: .modeOfPayment) // Encode modeOfPayment
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let amount = try container.decode(Double.self, forKey: .amount)
        let date = try container.decode(Date.self, forKey: .date)
        
        let categoryRawValue = try container.decode(String.self, forKey: .category)
        let category = ExpenseCategory(rawValue: categoryRawValue) ?? .others
        
        let recurrenceRawValue = try container.decode(String.self, forKey: .recurrence)
        let recurrence = RecurrenceInterval(rawValue: recurrenceRawValue) ?? .none
        
        let kakeiboTagRawValue = try container.decode(String.self, forKey: .kakeiboTag)
        let kakeiboTag = KakeiboTag(rawValue: kakeiboTagRawValue) ?? .needs
        
        let modeOfPaymentRawValue = try container.decode(String.self, forKey: .modeOfPayment)
        let modeOfPayment = ModeOfPayment(rawValue: modeOfPaymentRawValue) ?? .other
        
        self.init(title: title, amount: amount, date: date, category: category, recurrence: recurrence, kakeiboTag: kakeiboTag, modeOfPayment: modeOfPayment)
        self.id = id
    }
}
