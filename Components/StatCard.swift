//
//  StatCard.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Compact stat display card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack {
        StatCard(title: "Total", value: "$1,234", icon: "dollarsign.circle.fill", color: .green)
        StatCard(title: "Count", value: "42", icon: "number.circle.fill", color: .blue)
    }
    .padding()
    .background(Color.black)
}
