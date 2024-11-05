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

    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedDate: Date

    private var expense: Expense

    init(expense: Expense) {
        self.expense = expense
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(expense.amount))
        _selectedCategory = State(initialValue: expense.category)
        _selectedDate = State(initialValue: expense.date)
    }

    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)

            Picker("Category", selection: $selectedCategory) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }

            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)

            Button("Save Changes") {
                if let expenseAmount = Double(amount) {
                    expense.title = title
                    expense.amount = expenseAmount
                    expense.date = selectedDate
                    expense.category = selectedCategory
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Expense")
    }
}
