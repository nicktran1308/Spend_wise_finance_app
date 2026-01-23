import SwiftUI
import SwiftData

/// Sheet for creating a new expense category
struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var budget = ""
    @State private var selectedColorHex = "#34C759"
    
    // MARK: - Options
    
    private let iconOptions = [
        "fork.knife", "cart.fill", "bag.fill", "house.fill",
        "car.fill", "bolt.fill", "gamecontroller.fill", "film.fill",
        "heart.fill", "cross.case.fill", "book.fill", "dumbbell.fill",
        "airplane", "tram.fill", "gift.fill", "ellipsis.circle.fill"
    ]
    
    private let colorOptions = [
        "#34C759", "#007AFF", "#FF9500", "#FF6B6B",
        "#AF52DE", "#5856D6", "#8E8E93"
    ]
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    previewHeader
                    nameField
                    iconPicker
                    colorPicker
                    budgetField
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var previewHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: selectedColorHex).opacity(0.2))
                    .frame(width: 52, height: 52)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: selectedColorHex))
            }
            
            Text(name.isEmpty ? "Category Name" : name)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("e.g., Groceries", text: $name)
                .textInputAutocapitalization(.words)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 10)], spacing: 10) {
                ForEach(iconOptions, id: \.self) { option in
                    Button {
                        icon = option
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(icon == option ? Color.accentBlue.opacity(0.15) : Color.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(icon == option ? Color.accentBlue : Color.borderColor, lineWidth: 1)
                                )
                            
                            Image(systemName: option)
                                .font(.system(size: 20))
                                .foregroundStyle(icon == option ? Color.accentBlue : .secondary)
                        }
                        .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { hex in
                    Button {
                        selectedColorHex = hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(hex == selectedColorHex ? Color.primary : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var budgetField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Budget")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("$")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                TextField("0", text: $budget)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            .padding()
            .background(Color.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Actions
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let budgetValue = Double(budget) ?? 0
        let category = Category(
            name: trimmedName,
            icon: icon,
            colorHex: selectedColorHex,
            budget: max(0, budgetValue),
            isIncome: false
        )
        modelContext.insert(category)
        try? modelContext.save()
    }
}

#Preview {
    AddCategorySheet()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Category.self], inMemory: true)
}
