//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//

import SwiftUI

//struct AddExpenseView: View {
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var title: String = ""
//    @State private var amount: String = ""
//    @State private var selectedCategory: ExpenseCategory = .food
//    @State private var selectedDate: Date = Date()
//    @State private var recurrence: RecurrenceInterval = .none
//    @State private var selectedKakeiboTag: KakeiboTag = .needs // Default Kakeibo tag
//    
//    var body: some View {
//        Form {
//            TextField("Title", text: $title)
//            TextField("Amount", text: $amount)
//                .keyboardType(.decimalPad)
//            
//            Picker("Category", selection: $selectedCategory) {
//                ForEach(ExpenseCategory.allCases, id: \.self) { category in
//                    Text(category.rawValue).tag(category)
//                }
//            }
//            
//            DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
//
//            Picker("Recurrence", selection: $recurrence) {
//                ForEach(RecurrenceInterval.allCases, id: \.self) { interval in
//                    Text(interval.rawValue).tag(interval)
//                }
//            }
//            
//            Picker("Kakeibo Tag", selection: $selectedKakeiboTag) {
//                ForEach(KakeiboTag.allCases, id: \.self) { tag in
//                    Text(tag.rawValue).tag(tag)
//                }
//            }
//            
//            Button("Add Expense") {
//                if let expenseAmount = Double(amount) {
//                    let newExpense = Expense(title: title, amount: expenseAmount, date: selectedDate, category: selectedCategory, recurrence: recurrence, kakeiboTag: selectedKakeiboTag)
//                    context.insert(newExpense)
//                    dismiss()
//                }
//            }
//        }
//        .navigationTitle("Add Expense")
//    }
//}


struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var defaultDate: Date
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedDate: Date
    @State private var recurrence: RecurrenceInterval = .none
    @State private var selectedKakeiboTag: KakeiboTag = .needs
    
    init(defaultDate: Date) {
        self.defaultDate = defaultDate
        _selectedDate = State(initialValue: defaultDate) // Initialize selectedDate with defaultDate
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
            
            Button("Add Expense") {
                if let expenseAmount = Double(amount) {
                    let newExpense = Expense(title: title, amount: expenseAmount, date: selectedDate, category: selectedCategory, recurrence: recurrence, kakeiboTag: selectedKakeiboTag)
                    context.insert(newExpense)
                    dismiss()
                }
            }
        }
        .navigationTitle("Add Expense")
    }
}
