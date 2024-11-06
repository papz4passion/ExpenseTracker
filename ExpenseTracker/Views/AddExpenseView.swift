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


import SwiftUI
import SwiftData
import Foundation

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
    @State private var selectedModeOfPayment: ModeOfPayment = .cash // New state variable
    
    init(defaultDate: Date = Date()) {
        self.defaultDate = defaultDate
        _selectedDate = State(initialValue: defaultDate)
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
            
            Picker("Mode of Payment", selection: $selectedModeOfPayment) { // New picker
                ForEach(ModeOfPayment.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            
            Button("Add Expense") {
                if let expenseAmount = Double(amount) {
                    let newExpense = Expense(
                        title: title,
                        amount: expenseAmount,
                        date: selectedDate,
                        category: selectedCategory,
                        recurrence: recurrence,
                        kakeiboTag: selectedKakeiboTag,
                        modeOfPayment: selectedModeOfPayment
                    )
                    context.insert(newExpense)
                    dismiss()
                }
            }
        }
        .navigationTitle("Add Expense")
    }
}

#Preview {
    AddExpenseView()
}
