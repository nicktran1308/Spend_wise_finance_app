import Foundation
import SwiftData

/// Core data model for each income/expense entry
@Model
final class Transaction {
    // MARK: - Properties
    
    var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var note: String
    var isIncome: Bool
    
    // MARK: - Relationships
    
    var category: Category?
    
    // MARK: - Computed Properties
    
    /// Formatted amount string with sign
    var formattedAmount: String {
        let sign = isIncome ? "+" : "-"
        return "\(sign)$\(String(format: "%.2f", abs(amount)))"
    }
    
    /// Relative date string (Today, Yesterday, or formatted date)
    var relativeDateString: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Initialization
    
    init(
        title: String,
        amount: Double,
        date: Date = .now,
        note: String = "",
        isIncome: Bool = false,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.amount = abs(amount) // Store as positive, use isIncome for sign
        self.date = date
        self.note = note
        self.isIncome = isIncome
        self.category = category
    }
}

// MARK: - Sample Data

extension Transaction {
    /// Sample transactions for previews and testing
    static var samples: [Transaction] {
        [
            Transaction(title: "Grocery Store", amount: 82.50, note: "Weekly groceries", isIncome: false),
            Transaction(title: "Salary", amount: 3200, isIncome: true),
            Transaction(title: "Netflix", amount: 15.99, isIncome: false),
            Transaction(title: "Gas Station", amount: 45.00, isIncome: false),
            Transaction(title: "Freelance Work", amount: 500, note: "Logo design", isIncome: true)
        ]
    }
}
