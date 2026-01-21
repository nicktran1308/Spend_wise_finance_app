//
//  NotificationSettingsView.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Settings screen for notification preferences
struct NotificationSettingsView: View {
    private var settings = UserSettings.shared
    private var notificationManager = NotificationManager.shared
    
    @State private var dailyReminderEnabled = false
    @State private var reminderHour = 20
    @State private var reminderMinute = 0
    @State private var showingTimePicker = false
    
    var body: some View {
        List {
            // Authorization Section
            authorizationSection
            
            // Budget Alerts Section
            budgetAlertsSection
            
            // Daily Reminder Section
            dailyReminderSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationManager.checkAuthorizationStatus()
            loadReminderSettings()
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(hour: $reminderHour, minute: $reminderMinute) {
                saveReminderTime()
            }
            .presentationDetents([.height(300)])
        }
    }
    
    // MARK: - Authorization Section
    
    private var authorizationSection: some View {
        Section {
            if notificationManager.isAuthorized {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.incomeGreen)
                    Text("Notifications Enabled")
                    Spacer()
                }
            } else {
                Button {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                } label: {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundStyle(Color.accentBlue)
                        Text("Enable Notifications")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        } footer: {
            if !notificationManager.isAuthorized {
                Text("Enable notifications to receive budget alerts and reminders.")
            }
        }
    }
    
    // MARK: - Budget Alerts Section
    
    private var budgetAlertsSection: some View {
        Section("Budget Alerts") {
            Toggle(isOn: Binding(
                get: { settings.notificationsEnabled },
                set: { settings.notificationsEnabled = $0 }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget Warnings")
                    Text("Alert at 80%, 90%, and 100%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(!notificationManager.isAuthorized)
            
            // Threshold info
            VStack(alignment: .leading, spacing: 8) {
                thresholdRow(percent: 80, description: "Heads up", color: .yellow)
                thresholdRow(percent: 90, description: "Warning", color: .orange)
                thresholdRow(percent: 100, description: "Over budget", color: Color.expenseRed)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func thresholdRow(percent: Int, description: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text("\(percent)%")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Daily Reminder Section
    
    private var dailyReminderSection: some View {
        Section("Daily Reminder") {
            Toggle(isOn: $dailyReminderEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expense Reminder")
                    Text("Remind me to log expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(!notificationManager.isAuthorized)
            .onChange(of: dailyReminderEnabled) { _, newValue in
                if newValue {
                    notificationManager.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
                } else {
                    notificationManager.cancelDailyReminder()
                }
                UserDefaults.standard.set(newValue, forKey: "dailyReminderEnabled")
            }
            
            if dailyReminderEnabled {
                Button {
                    showingTimePicker = true
                } label: {
                    HStack {
                        Text("Reminder Time")
                        Spacer()
                        Text(formattedTime)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
    
    private func loadReminderSettings() {
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        reminderHour = UserDefaults.standard.integer(forKey: "reminderHour")
        reminderMinute = UserDefaults.standard.integer(forKey: "reminderMinute")
        
        // Default to 8:00 PM if not set
        if reminderHour == 0 && !UserDefaults.standard.bool(forKey: "reminderTimeSet") {
            reminderHour = 20
        }
    }
    
    private func saveReminderTime() {
        UserDefaults.standard.set(reminderHour, forKey: "reminderHour")
        UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute")
        UserDefaults.standard.set(true, forKey: "reminderTimeSet")
        
        if dailyReminderEnabled {
            notificationManager.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
        }
    }
}

// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var hour: Int
    @Binding var minute: Int
    let onSave: () -> Void
    
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Reminder Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                        hour = components.hour ?? 20
                        minute = components.minute ?? 0
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Set initial time
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                selectedTime = Calendar.current.date(from: components) ?? Date()
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
    .preferredColorScheme(.dark)
}
