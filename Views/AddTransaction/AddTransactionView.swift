import SwiftUI
import SwiftData
import WidgetKit

/// Add new transaction screen with category grid and haptic feedback
struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var note = ""
    @State private var showingSuccess = false
    
    // Haptic feedback generator
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Amount Display
                    amountSection
                    
                    // Type Toggle
                    typeToggle
                    
                    // Category Grid
                    categorySection
                    
                    // Details
                    detailsSection
                    
                    // Save Button
                    saveButton
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if showingSuccess {
                    successOverlay
                }
            }
        }
    }
    
    // MARK: - Amount Section
    
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text(isIncome ? "Income" : "Expense")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                TextField("0", text: $amount)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .foregroundStyle(isIncome ? Color.incomeGreen : .white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Type Toggle
    
    private var typeToggle: some View {
        HStack(spacing: 12) {
            typeButton(title: "Expense", isSelected: !isIncome) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isIncome = false
                    selectedCategory = nil
                }
            }
            
            typeButton(title: "Income", isSelected: isIncome) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isIncome = true
                    selectedCategory = nil
                }
            }
        }
    }
    
    private func typeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? (title == "Income" ? Color.incomeGreen : Color.expenseRed) : Color.cardBackground)
                .foregroundStyle(isSelected ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                ForEach(filteredCategories) { category in
                    categoryButton(category)
                }
            }
        }
    }
    
    private func categoryButton(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedCategory = isSelected ? nil : category
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : category.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .white : category.color)
                }
                
                Text(category.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? category.color.opacity(0.2) : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(spacing: 12) {
            // Title Field
            HStack {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                
                TextField("Title (e.g., Grocery shopping)", text: $title)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Date Picker
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                
                Spacer()
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Note Field
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                
                TextField("Note (optional)", text: $note)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button {
            saveTransaction()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Transaction")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Color.accentBlue : Color.accentBlue.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!isValid)
        .buttonStyle(.plain)
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.incomeGreen)
            
            Text("Saved!")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .transition(.opacity)
    }
    
    // MARK: - Computed Properties
    
    /// Categories filtered by income/expense type
    private var filteredCategories: [Category] {
        categories.filter { $0.isIncome == isIncome }
    }
    
    /// Form validation
    private var isValid: Bool {
        !title.isEmpty && (Double(amount) ?? 0) > 0
    }
    
    // MARK: - Actions
    
    /// Save transaction to database
    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        // Haptic feedback
        haptic.impactOccurred()
        
        // Create and save transaction
        let transaction = Transaction(
            title: title,
            amount: amountValue,
            date: date,
            note: note,
            isIncome: isIncome,
            category: selectedCategory
        )
        
        modelContext.insert(transaction)
        
        // Check budgets for notifications
        if let categories = try? modelContext.fetch(FetchDescriptor<Category>()),
           let transactions = try? modelContext.fetch(FetchDescriptor<Transaction>()) {
            BudgetNotificationService.shared.checkBudgets(categories: categories, transactions: transactions)
        }
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        // Show success feedback
        withAnimation {
            showingSuccess = true
        }
        
        // Reset form after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showingSuccess = false
            }
            resetForm()
        }
    }
    
    private func resetForm() {
        title = ""
        amount = ""
        note = ""
        date = Date()
        selectedCategory = nil
    }
}

#Preview {
    AddTransactionView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
