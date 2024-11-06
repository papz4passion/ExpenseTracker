//
//  EditExpenseView.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//


import SwiftUI

struct EditExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var expense: Expense
    
    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedDate: Date
    @State private var recurrence: RecurrenceInterval
    @State private var selectedKakeiboTag: KakeiboTag
    @State private var selectedModeOfPayment: ModeOfPayment // New state variable
    
    init(expense: Expense) {
        self.expense = expense
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(expense.amount))
        _selectedCategory = State(initialValue: expense.category)
        _selectedDate = State(initialValue: expense.date)
        _recurrence = State(initialValue: expense.recurrence)
        _selectedKakeiboTag = State(initialValue: expense.kakeiboTag)
        _selectedModeOfPayment = State(initialValue: expense.modeOfPayment) // Initialize with current value
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Amount", text: $amount).keyboardType(.decimalPad)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            
            DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
            
            Picker("Recurrence", selection: $recurrence) {
                ForEach(RecurrenceInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            
            Picker("Kakeibo Tag", selection: $selectedKakeiboTag) {
                ForEach(KakeiboTag.allCases, id: \.self) { tag in
                    Text(tag.rawValue).tag(tag)
                }
            }
            
            Picker("Mode of Payment", selection: $selectedModeOfPayment) { // New picker
                ForEach(ModeOfPayment.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            
            Button("Save Changes") {
                if let expenseAmount = Double(amount) {
                    do {
                        expense.title = title
                        expense.amount = expenseAmount
                        expense.date = selectedDate
                        expense.category = selectedCategory
                        expense.recurrence = recurrence
                        expense.kakeiboTag = selectedKakeiboTag
                        expense.modeOfPayment = selectedModeOfPayment
                        try context.save()
                    
                    } catch {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Expense")
    }
}

#Preview {
    EditExpenseView(expense: Expense(title: "Test", amount: Double(100), date: Date(), category: .bills, recurrence: .none, kakeiboTag: .needs, modeOfPayment: .cash))
}
