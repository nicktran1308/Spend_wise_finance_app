import Foundation
import SwiftUI
import SwiftData

/// Represents a spending/income category
@Model
final class Category {
    // MARK: - Properties
    
    var id: UUID
    var name: String
    var icon: String          // SF Symbol or emoji
    var colorHex: String      // Stored as hex for persistence
    var budget: Double        // Monthly budget limit (0 = no limit)
    var isIncome: Bool        // true for income categories
    
    // MARK: - Relationships
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]?
    
    // MARK: - Computed Properties
    
    /// SwiftUI Color from hex string
    var color: Color {
        Color(hex: colorHex)
    }
    
    /// Total spent this month in this category
    var spentThisMonth: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return transactions?
            .filter { !$0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount } ?? 0
    }
    
    /// Budget progress (0.0 to 1.0+)
    var budgetProgress: Double {
        guard budget > 0 else { return 0 }
        return spentThisMonth / budget
    }
    
    /// Remaining budget amount
    var remainingBudget: Double {
        max(0, budget - spentThisMonth)
    }
    
    // MARK: - Initialization
    
    init(
        name: String,
        icon: String,
        colorHex: String,
        budget: Double = 0,
        isIncome: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.budget = budget
        self.isIncome = isIncome
        self.transactions = []
    }
}

// MARK: - Default Categories

extension Category {
    /// Default expense categories
    static var defaultExpenseCategories: [Category] {
        [
            Category(name: "Food & Dining", icon: "fork.knife", colorHex: "#34C759", budget: 600),
            Category(name: "Transport", icon: "car.fill", colorHex: "#FF9500", budget: 300)
        ]
    }
    
    /// Default income categories
    static var defaultIncomeCategories: [Category] {
        [
            Category(name: "Salary", icon: "banknote.fill", colorHex: "#34C759", isIncome: true),
            Category(name: "Freelance", icon: "laptopcomputer", colorHex: "#007AFF", isIncome: true),
            Category(name: "Investments", icon: "chart.line.uptrend.xyaxis", colorHex: "#5856D6", isIncome: true),
            Category(name: "Other Income", icon: "plus.circle.fill", colorHex: "#8E8E93", isIncome: true)
        ]
    }
    
    /// All default categories
    static var allDefaults: [Category] {
        defaultExpenseCategories + defaultIncomeCategories
    }
}
