//
//  BudgetNotificationService.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//
import Foundation
import SwiftData

/// Service that checks budgets and triggers notifications
class BudgetNotificationService {
    // MARK: - Singleton
    
    static let shared = BudgetNotificationService()
    
    // MARK: - Properties
    
    private let notificationManager = NotificationManager.shared
    private let settings = UserSettings.shared
    
    /// Tracks which alerts have been sent (categoryId: [thresholds])
    private var sentAlerts: [String: Set<Int>] = [:]
    
    // MARK: - Initialization
    
    private init() {
        loadSentAlerts()
    }
    
    // MARK: - Budget Checking
    
    /// Check all category budgets and send alerts if needed
    func checkBudgets(categories: [Category], transactions: [Transaction]) {
        guard settings.notificationsEnabled else { return }
        
        let calendar = Calendar.current
        let startOfMonth = Date().startOfMonth
        
        for category in categories where category.budget > 0 && !category.isIncome {
            // Calculate spent amount this month
            let spent = transactions
                .filter { tx in
                    !tx.isIncome &&
                    tx.category?.id == category.id &&
                    tx.date >= startOfMonth
                }
                .reduce(0) { $0 + $1.amount }
            
            let percentUsed = Int((spent / category.budget) * 100)
            
            // Check thresholds
            checkAndNotify(
                category: category,
                percentUsed: percentUsed,
                spent: spent
            )
        }
    }
    
    /// Check threshold and send notification if not already sent
    private func checkAndNotify(category: Category, percentUsed: Int, spent: Double) {
        let categoryId = category.id.uuidString
        let thresholds = [80, 90, 100]
        
        // Initialize sent alerts for this category if needed
        if sentAlerts[categoryId] == nil {
            sentAlerts[categoryId] = []
        }
        
        for threshold in thresholds {
            // Check if we've crossed this threshold and haven't notified yet
            if percentUsed >= threshold && !sentAlerts[categoryId]!.contains(threshold) {
                // Send notification
                notificationManager.scheduleBudgetAlert(
                    categoryName: category.name,
                    percentUsed: threshold,
                    amountSpent: spent.asCurrency,
                    budgetAmount: category.budget.asCurrency
                )
                
                // Mark as sent
                sentAlerts[categoryId]?.insert(threshold)
                saveSentAlerts()
            }
        }
    }
    
    /// Reset alerts for new month
    func resetMonthlyAlerts() {
        sentAlerts.removeAll()
        saveSentAlerts()
    }
    
    // MARK: - Persistence
    
    private var alertsKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "sentBudgetAlerts-\(formatter.string(from: Date()))"
    }
    
    private func saveSentAlerts() {
        // Convert to storable format
        let storable = sentAlerts.mapValues { Array($0) }
        UserDefaults.standard.set(storable, forKey: alertsKey)
    }
    
    private func loadSentAlerts() {
        if let stored = UserDefaults.standard.dictionary(forKey: alertsKey) as? [String: [Int]] {
            sentAlerts = stored.mapValues { Set($0) }
        }
    }
}
