import SwiftUI
import SwiftData

/// Full list of all transactions (detailed view comes Day 3)
struct TransactionListView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var searchText = ""
    @State private var filterType: FilterType = .all
    
    // MARK: - Filter Enum
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
    }
    
    // MARK: - Computed Properties
    
    /// Filtered transactions based on search and type filter
    private var filteredTransactions: [Transaction] {
        transactions.filter { tx in
            // Type filter
            let matchesType: Bool
            switch filterType {
            case .all: matchesType  = true
            case .income: matchesType = tx.isIncome
            case .expense: matchesType = !tx.isIncome
            }
            
            // Search filter
            let matchesSearch = searchText.isEmpty || tx.title.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }
    
    /// Group transactions by date
    private var groupedTransactions: [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        
        // Group by start of day
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            calendar.startOfDay(for: tx.date)
        }
        
        // Sort by date descending
        return grouped
            .map { (date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            filterPicker
            
            // Transaction List
            if groupedTransactions.isEmpty {
                emptyState
            } else {
                transactionList
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search transactions")
    }
    
    
    // MARK: - Filter Picker
    
    private var filterPicker: some View {
        Picker("Filter", selection: $filterType) {
            ForEach(FilterType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        List {
            ForEach(groupedTransactions, id: \.date) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .listRowBackground(Color.cardBackground)
                            .listRowInsets(EdgeInsets())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(sectionHeader(for: group.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Transactions", systemImage: "tray")
        } description: {
            if !searchText.isEmpty {
                Text("No results for \"\(searchText)\"")
            } else if filterType != .all {
                Text("No \(filterType.rawValue.lowercased()) transactions yet")
            } else {
                Text("Add your first transaction using the + tab")
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    /// Format section header date
    private func sectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full day name
            return formatter.string(from: date)
        } else {
            return date.formatted(style: .medium)
        }
    }
    
    /// Delete a transaction
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            modelContext.delete(transaction)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
