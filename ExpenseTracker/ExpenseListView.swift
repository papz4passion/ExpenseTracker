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
            let isPastOrToday = Calendar.current.isDate(expense.date, inSameDayAs: selectedDate) || expense.date < selectedDate
            let isNotFuture = expense.date <= today
            return isPastOrToday && isNotFuture
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


// Share Sheet view for presenting the share activity
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Document Picker for selecting the JSON file
struct DocumentPicker: UIViewControllerRepresentable {
    var completion: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completion: (URL?) -> Void
        
        init(completion: @escaping (URL?) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion(urls.first)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(nil)
        }
    }
}

#Preview {
    ExpenseListView()
}


//struct ExpenseListView: View {
//    @Environment(\.modelContext) private var context
//    @Query var expenses: [Expense]
//    @State private var selectedDate: Date = Date()
//    
//    private let today = Date()
//    
//    var filteredExpenses: [Expense] {
//        expenses.filter { expense in
//            Calendar.current.isDate(expense.date, inSameDayAs: selectedDate) || expense.date < selectedDate
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Date navigation for previous and next days
//                HStack {
//                    Button(action: {
//                        changeDate(by: -1)
//                    }) {
//                        Image(systemName: "chevron.left")
//                    }
//                    
//                    Text("\(selectedDate, formatter: dateFormatter)")
//                        .font(.headline)
//                    
//                    Button(action: {
//                        changeDate(by: 1)
//                    }) {
//                        Image(systemName: "chevron.right")
//                    }
//                }
//                .padding()
//                
//                List(filteredExpenses) { expense in
//                    HStack {
//                        Circle()
//                            .fill(expense.category.color)
//                            .frame(width: 12, height: 12)
//                        
//                        VStack(alignment: .leading) {
//                            Text(expense.title)
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                            Text(expense.category.rawValue)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                        Text("$\(expense.amount, specifier: "%.2f")")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                    }
//                }
//                .navigationTitle("Expenses")
//                .onChange(of: selectedDate) { newDate in
//                    checkForRecurringExpenses(on: newDate)
//                }
//                .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        NavigationLink(destination: AddExpenseView(defaultDate: selectedDate)) {
//                            Text("Add Expense")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func changeDate(by days: Int) {
//        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
//            selectedDate = newDate
//        }
//    }
//    
//    // Check for recurring expenses without adding duplicates
//    private func checkForRecurringExpenses(on date: Date) {
//        let calendar = Calendar.current
//        
//        for expense in expenses where expense.recurrence != .none {
//            // Check if a recurring expense instance already exists for the current date
//            if isRecurringExpenseAlreadyAdded(for: expense, on: date) {
//                continue // Skip if already exists for this date
//            }
//            
//            // Determine if a recurring expense should be added based on the recurrence interval
//            let shouldAdd = shouldAddRecurringExpense(for: expense, on: date)
//            if shouldAdd {
//                // Create a new instance of the recurring expense for the date
//                let newExpense = Expense(
//                    title: expense.title,
//                    amount: expense.amount,
//                    date: date,
//                    category: expense.category,
//                    recurrence: expense.recurrence,
//                    kakeiboTag: expense.kakeiboTag
//                )
//                context.insert(newExpense)
//            }
//        }
//    }
//    
//    // Check if an instance of a recurring expense is already added for the selected date
//    private func isRecurringExpenseAlreadyAdded(for expense: Expense, on date: Date) -> Bool {
//        expenses.contains { existingExpense in
//            existingExpense.title == expense.title &&
//            existingExpense.amount == expense.amount &&
//            existingExpense.category == expense.category &&
//            existingExpense.kakeiboTag == expense.kakeiboTag &&
//            Calendar.current.isDate(existingExpense.date, inSameDayAs: date)
//        }
//    }
//    
//    private func shouldAddRecurringExpense(for expense: Expense, on date: Date) -> Bool {
//        let calendar = Calendar.current
//        switch expense.recurrence {
//        case .daily:
//            return true // Add every day
//        case .weekly:
//            // Add only if the day of the week matches the day of the week when the expense was created
//            return calendar.component(.weekday, from: expense.date) == calendar.component(.weekday, from: date)
//        case .monthly:
//            // Add only if the day of the month matches the day of the month when the expense was created
//            return calendar.component(.day, from: expense.date) == calendar.component(.day, from: date)
//        case .yearly:
//            // Add only if the month and day match the month and day when the expense was created
//            return calendar.component(.month, from: expense.date) == calendar.component(.month, from: date) &&
//            calendar.component(.day, from: expense.date) == calendar.component(.day, from: date)
//        case .none:
//            return false
//        }
//    }
//}
//
//private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .medium
//    return formatter
//}()
