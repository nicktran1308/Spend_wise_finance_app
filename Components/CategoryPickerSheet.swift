//
//  CategoryPickerSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI
import SwiftData

/// Modal sheet for selecting a category
struct CategoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]
    
    let isIncome: Bool
    @Binding var selectedCategory: Category?
    
    private var filteredCategories: [Category] {
        categories.filter { $0.isIncome == isIncome }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCategories) { category in
                Button {
                    selectedCategory = category
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundStyle(category.color)
                            .frame(width: 32)
                        
                        Text(category.name)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedCategory?.id == category.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentBlue)
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
