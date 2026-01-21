//
//  CurrencyPickerSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Sheet for selecting currency
struct CurrencyPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private var settings = UserSettings.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(UserSettings.availableCurrencies, id: \.code) { currency in
                    Button {
                        settings.currencyCode = currency.code
                        dismiss()
                    } label: {
                        HStack {
                            Text(currency.symbol)
                                .font(.title2)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading) {
                                Text(currency.code)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if settings.currencyCode == currency.code {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentBlue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CurrencyPickerSheet()
        .preferredColorScheme(.dark)
}
