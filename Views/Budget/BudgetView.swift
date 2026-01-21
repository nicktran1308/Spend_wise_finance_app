import SwiftUI
import SwiftData

/// Budget overview screen (detailed implementation Day 5)
struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Category> { !$0.isIncome })
    private var expenseCategories: [Category]
    @Query private var transactions: [Transaction]
    
    // Mark: - State
    
    @State private var selectedMonth = Date()
    @State private var editingCategory: Category?
    @State private var newBudgetAmount = ""
    
    // MARK: - Computed Properties
    
    
    /// Start of selected month
    private var monthStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth))!
    }
    
    /// End of selected month
    private var monthEnd: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
    }
    
    /// Month/Year display string
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    /// Transactions for selected month
    private var monthlyTransactions: [Transaction] {
        transactions.filter { tx in
            tx.date >= monthStart && tx.date <= monthEnd && !tx.isIncome
        }
    }
    
    /// Total spent in selected month
    private var totalSpent: Double {
        monthlyTransactions.reduce(0) { $0 + $1.amount }
    }
    
    /// Total budget across all categories
    private var totalBudget: Double {
        expenseCategories.reduce(0) { $0 + $1.budget }
    }
    
    /// Overall budget progress
    private var overallProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return totalSpent / totalBudget
    }
    
    /// Spending for a category in selected month
    private func spentInMonth(for category: Category) -> Double {
        monthlyTransactions
            .filter { $0.category?.id == category.id }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Budget progress for a category in selected month
    private func progressInMonth(for category: Category) -> Double {
        guard category.budget > 0 else { return 0 }
        return spentInMonth(for: category) / category.budget
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month Selector
                    monthSelector
                    
                    // Overall Summary Card
                    overallSummaryCard
                    
                    // Category Budgets
                    categoryBudgetsSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Budgets")
            .sheet(item: $editingCategory) { category in
                EditBudgetSheet(
                    category: category,
                    budgetAmount: $newBudgetAmount,
                    onSave: { saveBudget(for: category) }
                )
                .presentationDetents([.height(250)])
            }
        }
    }
    
    // MARK: - Month Selector
    
    private var monthSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.headline)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .disabled(Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Overall Summary Card
    
    private var overallSummaryCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Monthly Overview")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // Amounts
            HStack(alignment: .firstTextBaseline) {
                Text(totalSpent.asCurrency)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("of \(totalBudget.asCurrency)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            // Progress Bar
            ProgressBar(progress: overallProgress, color: progressColor(for: overallProgress))
            
            // Remaining
            HStack {
                if totalBudget > totalSpent {
                    Label("\((totalBudget - totalSpent).asCurrency) remaining", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.incomeGreen)
                } else {
                    Label("\((totalSpent - totalBudget).asCurrency) over budget", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.expenseRed)
                }
                Spacer()
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Category Budgets Section
    
    private var categoryBudgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Budgets")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(expenseCategories) { category in
                BudgetCategoryCard(
                    category: category,
                    spent: spentInMonth(for: category),
                    progress: progressInMonth(for: category),
                    onTap: {
                        newBudgetAmount = category.budget > 0 ? String(format: "%.0f", category.budget) : ""
                        editingCategory = category
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func progressColor(for progress: Double) -> Color {
        if progress > 1.0 {
            return Color.expenseRed
        } else if progress > 0.9 {
            return Color(hex: "#FF9500") // Orange warning
        } else {
            return Color.incomeGreen
        }
    }
    
    private func saveBudget(for category: Category) {
        guard let amount = Double(newBudgetAmount) else { return }
        category.budget = amount
        try? modelContext.save()
        editingCategory = nil
    }
}
#Preview {
    BudgetView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
