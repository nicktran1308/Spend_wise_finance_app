import SwiftUI
import SwiftData

/// Home screen showing balance overview and recent transactions
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    // MARK: - Computed Properties
    
    /// Total balance (income - expenses)
    private var totalBalance: Double {
        transactions.reduce(0) { sum, tx in
            sum + (tx.isIncome ? tx.amount : -tx.amount)
        }
    }
    
    /// Total income this month
    private var monthlyIncome: Double {
        transactions
            .filter { $0.isIncome && $0.date.isInCurrentMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Total expenses this month
    private var monthlyExpenses: Double {
        transactions
            .filter { !$0.isIncome && $0.date.isInCurrentMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Recent transactions (last 5)
    private var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Card
                    balanceCard
                    
                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Greeting
    
    /// Dynamic greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
    
    // MARK: - Balance Card
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total Balance
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(totalBalance.asCurrency)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Income & Expenses Row
            HStack(spacing: 32) {
                // Income
                VStack(alignment: .leading, spacing: 4) {
                    Label("Income", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.incomeGreen)
                    
                    Text(monthlyIncome.asCurrency)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                // Expenses
                VStack(alignment: .leading, spacing: 4) {
                    Label("Expenses", systemImage: "arrow.down.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.expenseRed)
                    
                    Text(monthlyExpenses.asCurrency)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#1E3A5F"), Color(hex: "#0D1B2A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Recent Transactions Section
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                NavigationLink {
                    TransactionListView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentBlue)
                }
            }
            
            // Transaction List
            if recentTransactions.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(recentTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(transaction)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        
                        if transaction.id != recentTransactions.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Tap the + tab to add your first transaction")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
