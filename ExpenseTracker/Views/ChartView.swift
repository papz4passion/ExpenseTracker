//
//  ChartView.swift
//  ExpenseTracker
//
//  Created by Palaneappan Rajalingam on 04/11/24.
//


import SwiftUI
import Charts
import _SwiftData_SwiftUI

//struct ChartView: View {
//    @Environment(\.modelContext) private var context
//    @Query var expenses: [Expense]
//    
//    @State private var selectedInterval: RecurrenceInterval = .none
//    @State private var chartType: ChartType = .bar // Toggle between bar and pie charts
//    @State private var selectedCategory: ExpenseCategory? // Track selected category for pie chart interaction
//    
//    var filteredExpenses: [Expense] {
//        // Filter expenses based on selected interval
//        switch selectedInterval {
//        case .daily:
//            return expenses.filter { Calendar.current.isDateInToday($0.date) }
//        case .weekly:
//            return expenses.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
//        case .monthly:
//            return expenses.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
//        case .yearly:
//            return expenses.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .year) }
//        case .none:
//            return expenses
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            Picker("Interval", selection: $selectedInterval) {
//                Text("Daily").tag(RecurrenceInterval.daily)
//                Text("Weekly").tag(RecurrenceInterval.weekly)
//                Text("Monthly").tag(RecurrenceInterval.monthly)
//                Text("Yearly").tag(RecurrenceInterval.yearly)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
//            
//            Picker("Chart Type", selection: $chartType) {
//                Text("Bar").tag(ChartType.bar)
//                Text("Pie").tag(ChartType.pie)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
//            
//            if chartType == .bar {
//                BarChart(expenses: filteredExpenses)
//                    .padding()
//            } else {
//                InteractivePieChart(expenses: filteredExpenses, selectedCategory: $selectedCategory)
//                    .padding()
//            }
//        }
//        .navigationTitle("Expense Charts")
//    }
//}

struct ChartView: View {
    @Environment(\.modelContext) private var context
    @Query var expenses: [Expense]
    
    @State private var selectedInterval: RecurrenceInterval = .none
    @State private var chartType: ChartType = .bar // Toggle between bar and pie charts
    @State private var selectedKakeiboTag: KakeiboTag? = nil // Filter by Kakeibo tag
    
    var filteredExpenses: [Expense] {
        let intervalFiltered = expenses.filter { expense in
            switch selectedInterval {
            case .daily: return Calendar.current.isDateInToday(expense.date)
            case .weekly: return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .monthly: return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .month)
            case .yearly: return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .year)
            case .none: return true
            }
        }
        if let selectedTag = selectedKakeiboTag {
            return intervalFiltered.filter { $0.kakeiboTag == selectedTag }
        } else {
            return intervalFiltered
        }
    }
    
    var body: some View {
        VStack {
            Picker("Interval", selection: $selectedInterval) {
                Text("Daily").tag(RecurrenceInterval.daily)
                Text("Weekly").tag(RecurrenceInterval.weekly)
                Text("Monthly").tag(RecurrenceInterval.monthly)
                Text("Yearly").tag(RecurrenceInterval.yearly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Kakeibo Tag", selection: $selectedKakeiboTag) {
                Text("All").tag(KakeiboTag?.none)
                ForEach(KakeiboTag.allCases, id: \.self) { tag in
                    Text(tag.rawValue).tag(tag as KakeiboTag?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Chart Type", selection: $chartType) {
                Text("Bar").tag(ChartType.bar)
                Text("Pie").tag(ChartType.pie)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if chartType == .bar {
                BarChart(expenses: filteredExpenses)
                    .padding()
            } else {
                InteractivePieChart(expenses: filteredExpenses, selectedCategory: .constant(nil))
                    .padding()
            }
        }
        .navigationTitle("Expense Charts")
    }
}


enum ChartType {
    case bar, pie
}

struct BarChart: View {
    var expenses: [Expense]
    
    var body: some View {
        Chart {
            ForEach(expenses) { expense in
                BarMark(
                    x: .value("Category", expense.category.rawValue),
                    y: .value("Amount", expense.amount)
                )
                .foregroundStyle(by: .value("Category", expense.category.rawValue))
            }
        }
        .chartXAxisLabel("Category")
        .chartYAxisLabel("Amount")
    }
}

struct InteractivePieChart: View {
    var expenses: [Expense]
    @Binding var selectedCategory: ExpenseCategory?
    
    var body: some View {
        let expensesByCategory = Dictionary(grouping: expenses, by: { $0.category })
        let totalAmount = expenses.map { $0.amount }.reduce(0, +)
        
        ZStack {
            Chart {
                ForEach(expensesByCategory.keys.sorted(), id: \.self) { category in
                    let totalCategoryAmount = expensesByCategory[category]?.map { $0.amount }.reduce(0, +) ?? 0
                    let isSelected = selectedCategory == category
                    
                    SectorMark(
                        angle: .value("Amount", totalCategoryAmount),
                        innerRadius: .ratio(isSelected ? 0.3 : 0.5),
                        outerRadius: .ratio(isSelected ? 1.0 : 0.8)
                    )
                    .foregroundStyle(category.color)
                }
            }
            .chartLegend(position: .trailing)
            
            // Add transparent buttons over each category for interactivity
            ForEach(expensesByCategory.keys.sorted(), id: \.self) { category in
                let totalCategoryAmount = expensesByCategory[category]?.map { $0.amount }.reduce(0, +) ?? 0
                
                Button(action: {
                    withAnimation {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }) {
                    // Invisible tappable area aligned with each sector
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 200, height: 200)
                }
                .offset(x: cos(angleForCategory(category, totalCategoryAmount: totalCategoryAmount, totalAmount: totalAmount)) * 50,
                        y: sin(angleForCategory(category, totalCategoryAmount: totalCategoryAmount, totalAmount: totalAmount)) * 50)
            }
            
            // Overlay details for selected category
            if let selectedCategory = selectedCategory, let categoryExpenses = expensesByCategory[selectedCategory] {
                VStack {
                    Text(selectedCategory.rawValue)
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Total: $\(categoryExpenses.map { $0.amount }.reduce(0, +), specifier: "%.2f")")
                        .font(.subheadline)
                        .padding(.bottom, 4)
                    
                    ForEach(categoryExpenses, id: \.id) { expense in
                        HStack {
                            Text(expense.title)
                            Spacer()
                            Text("$\(expense.amount, specifier: "%.2f")")
                        }
                        .padding(.horizontal)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 10))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale) // Animate appearance
            }
        }
    }
    
    // Helper function to determine angle offset for each category
    private func angleForCategory(_ category: ExpenseCategory, totalCategoryAmount: Double, totalAmount: Double) -> CGFloat {
        let angleFraction = totalCategoryAmount / totalAmount
        return CGFloat(angleFraction * 2 * .pi) - .pi / 2
    }
}
