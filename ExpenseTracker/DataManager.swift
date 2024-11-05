//
//  DataManager.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 05/11/24.
//

import SwiftUI
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    // Export expenses to JSON and present a share sheet to save or share
    func exportExpensesToJSON(expenses: [Expense], completion: @escaping (URL?) -> Void) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            // Encode expenses to JSON data
            let jsonData = try encoder.encode(expenses)
            
            // Create a file URL for saving the JSON file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ExpensesExport.json")
            try jsonData.write(to: tempURL)
            
            completion(tempURL) // Return the file URL
        } catch {
            print("Error exporting expenses to JSON: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // Import expenses from a JSON file URL
    func importExpensesFromJSON(url: URL, context: ModelContext, completion: @escaping (Bool) -> Void) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let jsonData = try Data(contentsOf: url)
            let importedExpenses = try decoder.decode([Expense].self, from: jsonData)
            
            // Insert imported expenses into SwiftData context
            Task {
                for expense in importedExpenses {
                    _ = Expense(
                        title: expense.title,
                        amount: expense.amount,
                        date: expense.date,
                        category: expense.category,
                        recurrence: expense.recurrence,
                        kakeiboTag: expense.kakeiboTag
                    )
                }
                try context.save()
                completion(true)
            }
        } catch {
            print("Error importing expenses from JSON: \(error.localizedDescription)")
            completion(false)
        }
    }
}
