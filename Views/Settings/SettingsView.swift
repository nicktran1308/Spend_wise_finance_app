import SwiftUI
import SwiftData

/// Settings screen with user preferences
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var categories: [Category]
    
    private var settings = UserSettings.shared
    
    // MARK: - State
    
    @State private var showingProfile = false
    @State private var showingCurrencyPicker = false
    @State private var showingAppearancePicker = false
    @State private var showingExportSheet = false
    @State private var showingResetAlert = false
    @State private var showingResetSuccess = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                profileSection
                
                // Preferences Section
                preferencesSection
                
                // Data Section
                dataSection
                
                // About Section
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Settings")
            .sheet(isPresented: $showingProfile) {
                ProfileEditSheet()
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerSheet()
            }
            .sheet(isPresented: $showingAppearancePicker) {
                AppearancePickerSheet()
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataSheet(transactions: transactions)
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) { resetAllData() }
            } message: {
                Text("This will delete all transactions and reset budgets. This cannot be undone.")
            }
            .overlay {
                if showingResetSuccess {
                    resetSuccessOverlay
                }
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Section {
            Button {
                showingProfile = true
            } label: {
                HStack(spacing: 14) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.accentBlue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                        
                        Text(settings.userName.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    
                    // Name & Email
                    VStack(alignment: .leading, spacing: 2) {
                        Text(settings.userName.isEmpty ? "Add Name" : settings.userName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(settings.userEmail.isEmpty ? "Add Email" : settings.userEmail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        Section("Preferences") {
            // Currency
            Button {
                showingCurrencyPicker = true
            } label: {
                settingsRow(
                    icon: "dollarsign.circle.fill",
                    title: "Currency",
                    value: "\(settings.currencyCode) (\(settings.currencySymbol))",
                    color: Color.incomeGreen
                )
            }
            .buttonStyle(.plain)
            
            // Appearance
            Button {
                showingAppearancePicker = true
            } label: {
                settingsRow(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    value: settings.appearanceMode.rawValue,
                    color: .purple
                )
            }
            .buttonStyle(.plain)
            
            // Notifications
            NavigationLink {
                NotificationSettingsView()
            } label: {
                settingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    value: settings.notificationsEnabled ? "On" : "Off",
                    color: Color.expenseRed
                )
            }
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section("Data") {
            // Export
            Button {
                showingExportSheet = true
            } label: {
                settingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Export Data",
                    value: "\(transactions.count) transactions",
                    color: Color.accentBlue
                )
            }
            .buttonStyle(.plain)
            
            // Reset
            Button {
                showingResetAlert = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "trash.fill")
                        .font(.title2)
                        .foregroundStyle(Color.expenseRed)
                        .frame(width: 32)
                    
                    Text("Reset All Data")
                        .foregroundStyle(Color.expenseRed)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("About") {
            settingsRow(
                icon: "info.circle.fill",
                title: "Version",
                value: "1.0.0",
                color: .gray
            )
            
            Link(destination: URL(string: "https://apple.com")!) {
                settingsRow(
                    icon: "star.fill",
                    title: "Rate App",
                    value: "",
                    color: .yellow
                )
            }
            .buttonStyle(.plain)
            
            Link(destination: URL(string: "mailto:support@spendwise.app")!) {
                settingsRow(
                    icon: "envelope.fill",
                    title: "Send Feedback",
                    value: "",
                    color: Color.accentBlue
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)
            
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private var resetSuccessOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.incomeGreen)
            
            Text("Data Reset!")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .transition(.opacity)
    }
    
    // MARK: - Actions
    
    private func resetAllData() {
        // Delete all transactions
        for transaction in transactions {
            modelContext.delete(transaction)
        }
        
        // Reset category budgets
        for category in categories {
            category.budget = 0
        }
        
        try? modelContext.save()
        
        // Show success
        withAnimation {
            showingResetSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showingResetSuccess = false
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Transaction.self, Category.self], inMemory: true)
}
