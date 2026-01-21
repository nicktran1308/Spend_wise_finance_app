//
//  ApperancePickerSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Sheet for selecting appearance mode
struct AppearancePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private var settings = UserSettings.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(UserSettings.AppearanceMode.allCases, id: \.self) { mode in
                    Button {
                        settings.appearanceMode = mode
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: iconName(for: mode))
                                .font(.title2)
                                .foregroundStyle(iconColor(for: mode))
                                .frame(width: 40)
                            
                            Text(mode.rawValue)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if settings.appearanceMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentBlue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func iconName(for mode: UserSettings.AppearanceMode) -> String {
        switch mode {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    private func iconColor(for mode: UserSettings.AppearanceMode) -> Color {
        switch mode {
        case .system: return .gray
        case .light: return .orange
        case .dark: return .purple
        }
    }
}

#Preview {
    AppearancePickerSheet()
        .preferredColorScheme(.dark)
}
