//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ExpenseListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
