import SwiftUI
import SwiftData
import Charts

/// Statistics and charts screen with Swift Charts
struct StatsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query(filter: #Predicate<Category> { !$0.isIncome })
    private var expenseCategories: [Category]
    
    // MARK: - State
    
    @State private var selectedPeriod: TimePeriod = .week
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    // MARK: - Date Ranges
    
    private var periodStartDate: Date {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .week:
            return calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))!
        case .month:
            return calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: Date()))!
        case .year:
            return calendar.date(byAdding: .month, value: -11, to: Date().startOfMonth)!
        }
    }
    
    // MARK: - Filtered Data
    
    private var periodTransactions: [Transaction] {
        transactions.filter { !$0.isIncome && $0.date >= periodStartDate }
    }
    
    private var totalSpent: Double {
        periodTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private var transactionCount: Int {
        periodTransactions.count
    }
    
    private var averagePerTransaction: Double {
        guard transactionCount > 0 else { return 0 }
        return totalSpent / Double(transactionCount)
    }
    
    // MARK: - Chart Data
    
    /// Daily spending data for bar chart
    private var dailySpending: [DailySpend] {
        let calendar = Calendar.current
        let days: Int
        
        switch selectedPeriod {
        case .week: days = 7
        case .month: days = 30
        case .year: days = 12 // Monthly for year view
        }
        
        if selectedPeriod == .year {
            // Group by month for year view
            return (0..<12).map { monthOffset in
                let date = calendar.date(byAdding: .month, value: -11 + monthOffset, to: Date().startOfMonth)!
                let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: date)!
                
                let amount = transactions
                    .filter { !$0.isIncome && $0.date >= date && $0.date <= monthEnd }
                    .reduce(0) { $0 + $1.amount }
                
                return DailySpend(date: date, amount: amount)
            }
        } else {
            // Group by day for week/month view
            return (0..<days).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: -days + 1 + dayOffset, to: calendar.startOfDay(for: Date()))!
                
                let amount = transactions
                    .filter { !$0.isIncome && calendar.isDate($0.date, inSameDayAs: date) }
                    .reduce(0) { $0 + $1.amount }
                
                return DailySpend(date: date, amount: amount)
            }
        }
    }
    
    /// Category spending data for pie chart
    private var categorySpending: [CategorySpend] {
        expenseCategories.compactMap { category in
            let amount = periodTransactions
                .filter { $0.category?.id == category.id }
                .reduce(0) { $0 + $1.amount }
            
            guard amount > 0 else { return nil }
            return CategorySpend(category: category, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    /// Top spending category
    private var topCategory: Category? {
        categorySpending.first?.category
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    periodPicker
                    
                    // Summary Cards
                    summaryCards
                    
                    // Spending Chart
                    spendingChartCard
                    
                    // Category Breakdown
                    categoryBreakdownCard
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - Period Picker
    
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Spent",
                value: totalSpent.asCurrency,
                icon: "arrow.down.circle.fill",
                color: Color.expenseRed
            )
            
            StatCard(
                title: "Transactions",
                value: "\(transactionCount)",
                icon: "list.bullet.circle.fill",
                color: Color.accentBlue
            )
            
            StatCard(
                title: "Average",
                value: averagePerTransaction.asCurrency,
                icon: "divide.circle.fill",
                color: Color.incomeGreen
            )
        }
    }
    
    // MARK: - Spending Chart Card
    
    private var spendingChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedPeriod == .year ? "Monthly Spending" : "Daily Spending")
                .font(.headline)
            
            if dailySpending.allSatisfy({ $0.amount == 0 }) {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No spending data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart(dailySpending) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: selectedPeriod == .year ? .month : .day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.accentBlue.gradient)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    if selectedPeriod == .year {
                        AxisMarks(values: .stride(by: .month)) { value in
                            AxisValueLabel(format: .dateTime.month(.narrow))
                        }
                    } else if selectedPeriod == .month {
                        AxisMarks(values: .stride(by: .day, count: 7)) { value in
                            AxisValueLabel(format: .dateTime.day())
                        }
                    } else {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount.asCompactCurrency)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Category Breakdown Card
    
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(.headline)
            
            if categorySpending.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No category data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                HStack(spacing: 20) {
                    // Donut Chart
                    Chart(categorySpending) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 140, height: 140)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(categorySpending.prefix(5)) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.category.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(item.category.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(item.amount.asCurrency)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
            
            // Top Category Highlight
            if let top = topCategory {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Top: \(top.name)")
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
#Preview {
    StatsView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
