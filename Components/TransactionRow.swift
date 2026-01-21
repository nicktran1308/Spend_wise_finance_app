import SwiftUI

/// Single transaction row for lists
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 14) {
            // Category Icon
            categoryIcon
            
            // Title & Category
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text(transaction.category?.name ?? "Uncategorized")
                    Text("•")
                    Text(transaction.relativeDateString)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.isIncome ?  Color.incomeGreen : .white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Category Icon
    
    private var categoryIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(iconBackgroundColor.opacity(0.2))
                .frame(width: 44, height: 44)
            
            Image(systemName: transaction.category?.icon ?? "questionmark.circle")
                .font(.system(size: 18))
                .foregroundStyle(iconBackgroundColor)
        }
    }
    
    /// Icon background color from category or default
    private var iconBackgroundColor: Color {
        if let category = transaction.category {
            return category.color
        }
        return transaction.isIncome ? .incomeGreen : .expenseRed
    }
    
    private var accessibilityDescription: String {
        let type = transaction.isIncome ? "Income" : "Expense"
        let category = transaction.category?.name ?? "Uncategorized"
        return "\(type): \(transaction.title), \(transaction.formattedAmount), \(category), \(transaction.relativeDateString)"
    }
}

#Preview {
    VStack(spacing: 0) {
        TransactionRow(transaction: Transaction(
            title: "Grocery Store",
            amount: 82.50,
            isIncome: false
        ))
        
        Divider()
        
        TransactionRow(transaction: Transaction(
            title: "Salary Deposit",
            amount: 3200,
            isIncome: true
        ))
    }
    .background(Color.cardBackground)
    .preferredColorScheme(.dark)
}
