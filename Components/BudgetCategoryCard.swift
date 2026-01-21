//
//  BudgetCategoryCard.swift.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//
import SwiftUI

/// Card displaying a single category's budget progress
struct BudgetCategoryCard: View {
    let category: Category
    let spent: Double
    let progress: Double
    let onTap: () -> Void
    
    private var progressColor: Color {
        if progress > 1.0 {
            return Color.expenseRed
        } else if progress > 0.9 {
            return Color(hex: "#FF9500")
        } else {
            return category.color
        }
    }
    
    private var remainingAmount: Double {
        max(0, category.budget - spent)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header Row
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(category.color)
                    }
                    
                    // Name & Remaining
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        
                        if category.budget > 0 {
                            Text("\(remainingAmount.asCurrency) left")
                                .font(.caption)
                                .foregroundStyle(progress > 1.0 ? Color.expenseRed : .secondary)
                        } else {
                            Text("No budget set")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Amount
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(spent.asCurrency)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        
                        if category.budget > 0 {
                            Text("of \(category.budget.asCurrency)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Edit indicator
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                // Progress Bar
                if category.budget > 0 {
                    ProgressBar(
                        progress: progress,
                        color: progressColor,
                        height: 6
                    )
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        BudgetCategoryCard(
            category: Category(name: "Food", icon: "fork.knife", colorHex: "#34C759", budget: 500),
            spent: 320,
            progress: 0.64,
            onTap: {}
        )
        
        BudgetCategoryCard(
            category: Category(name: "Shopping", icon: "bag.fill", colorHex: "#AF52DE", budget: 200),
            spent: 195,
            progress: 0.975,
            onTap: {}
        )
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
