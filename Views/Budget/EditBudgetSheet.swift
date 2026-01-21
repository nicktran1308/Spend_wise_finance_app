//
//  EditBudgetSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Sheet for editing a category's budget amount
struct EditBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let category: Category
    @Binding var budgetAmount: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Category Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundStyle(category.color)
                    }
                    
                    Text(category.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                // Budget Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("$")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        
                        TextField("0", text: $budgetAmount)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    EditBudgetSheet(
        category: Category(name: "Food", icon: "fork.knife", colorHex: "#34C759", budget: 500),
        budgetAmount: .constant("500"),
        onSave: {}
    )
    .preferredColorScheme(.dark)
}
