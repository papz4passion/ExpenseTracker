//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//


import SwiftUI
import SwiftData
import Foundation

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context
    @Query var expenses: [Expense]
    
    @State private var exportURL: URL? // For sharing the exported JSON file
    @State private var showingShareSheet = false // State to show the share sheet
    @State private var selectedDate: Date = Date() // Track the selected date
    
    private let today = Date()
    
    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            return Calendar.current.isDate(expense.date, equalTo: selectedDate, toGranularity: .day)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Date navigation
                HStack(alignment: .center, spacing: 16) {
                    Spacer()
                    Button(action: { changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    // Date Picker to quickly jump to a specific date
                    DatePicker("", selection: $selectedDate, in: ...today, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    // Compact style for minimal space
                    
                    Button(action: { changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(Calendar.current.isDate(selectedDate, inSameDayAs: today)) // Disable forward navigation if on today's date
                    
                    Spacer()
                }
                .padding()
                
                List {
                    ForEach(filteredExpenses) { expense in
                        NavigationLink(destination: EditExpenseView(expense: expense)) {
                            HStack {
                                Circle()
                                    .fill(expense.category.color)
                                    .frame(width: 12, height: 12) // Color indicator
                                
                                VStack(alignment: .leading) {
                                    Text(expense.title)
                                        .font(.headline)
                                    Text("\(expense.category.rawValue)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Paid via \(expense.modeOfPayment.rawValue)").font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("₹\(expense.amount, specifier: "%.2f")")
                                    .font(.headline)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(filteredExpenses[index])
                        }
                    }
                }
                .navigationTitle("Daily Expenses")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        
                        Button() {
                            DocumentPicker { url in
                                if let url = url {
                                    DataManager.shared.importExpensesFromJSON(url: url, context: context) { result in
                                        Alert(title: Text(result ? "Success" : "Error"), message: Text(result ? "Successfully imported expenses." : "Error importing expenses."), dismissButton: .default(Text("OK")))
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        
                        Button() {
                            exportData()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        NavigationLink() {
                            ChartView()
                        } label: {
                            Image(systemName: "chart.bar")
                        }
                        
                        NavigationLink() {
                            AddExpenseView(defaultDate: selectedDate)
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let exportURL = exportURL {
                        ShareSheet(activityItems: [exportURL])
                    }
                }
            }
        }
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    // Export data and open the share sheet
    private func exportData() {
        DataManager.shared.exportExpensesToJSON(expenses: expenses) { url in
            if let url = url {
                exportURL = url
                showingShareSheet = true
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    ExpenseListView()
}
