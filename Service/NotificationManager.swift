//
//  NotificationManager.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import Foundation
import UserNotifications

/// Manages local notifications for budget alerts and reminders
@Observable
class NotificationManager {
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Properties
    
    var isAuthorized = false
    var pendingNotifications: [UNNotificationRequest] = []
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check current notification authorization status
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - Budget Alerts
    
    /// Schedule a budget alert notification
    func scheduleBudgetAlert(
        categoryName: String,
        percentUsed: Int,
        amountSpent: String,
        budgetAmount: String
    ) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Budget Alert: \(categoryName)"
        content.sound = .default
        
        switch percentUsed {
        case 80..<90:
            content.body = "You've used 80% of your \(categoryName) budget (\(amountSpent) of \(budgetAmount))"
            content.interruptionLevel = .passive
        case 90..<100:
            content.body = "Warning: 90% of your \(categoryName) budget spent! (\(amountSpent) of \(budgetAmount))"
            content.interruptionLevel = .timeSensitive
        case 100...:
            content.body = "🚨 You've exceeded your \(categoryName) budget! (\(amountSpent) of \(budgetAmount))"
            content.interruptionLevel = .timeSensitive
        default:
            return
        }
        
        // Unique identifier for this category/threshold combo
        let identifier = "budget-\(categoryName.lowercased())-\(percentUsed)"
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Daily Reminder
    
    /// Schedule daily expense logging reminder
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        guard isAuthorized else { return }
        
        // Remove existing daily reminder
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "SpendWise Reminder"
        content.body = "Don't forget to log your expenses today! 📝"
        content.sound = .default
        content.interruptionLevel = .passive
        
        // Schedule for specific time daily
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
    
    /// Cancel daily reminder
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }
    
    // MARK: - Management
    
    /// Fetch all pending notifications
    func fetchPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        await MainActor.run {
            pendingNotifications = requests
        }
    }
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
        pendingNotifications = []
    }
    
    /// Remove specific notification
    func removeNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        pendingNotifications.removeAll { $0.identifier == identifier }
    }
}
