//
//  UserSettings.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import Foundation
import SwiftUI

/// User preferences stored in UserDefaults
@Observable
class UserSettings {
    // MARK: - Singleton
    
    static let shared = UserSettings()
    
    // MARK: - Keys
    
    private enum Keys {
        static let userName = "userName"
        static let userEmail = "userEmail"
        static let currencyCode = "currencyCode"
        static let appearanceMode = "appearanceMode"
        static let defaultCategoryId = "defaultCategoryId"
        static let notificationsEnabled = "notificationsEnabled"
        static let budgetAlertThreshold = "budgetAlertThreshold"
    }
    
    // MARK: - Properties
    
    var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Keys.userName) }
    }
    
    var userEmail: String {
        didSet { UserDefaults.standard.set(userEmail, forKey: Keys.userEmail) }
    }
    
    var currencyCode: String {
        didSet { UserDefaults.standard.set(currencyCode, forKey: Keys.currencyCode) }
    }
    
    var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearanceMode) }
    }
    
    var defaultCategoryId: String? {
        didSet { UserDefaults.standard.set(defaultCategoryId, forKey: Keys.defaultCategoryId) }
    }
    
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    
    var budgetAlertThreshold: Double {
        didSet { UserDefaults.standard.set(budgetAlertThreshold, forKey: Keys.budgetAlertThreshold) }
    }
    
    // MARK: - Appearance Enum
    
    enum AppearanceMode: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    // MARK: - Currency Options
    
    static let availableCurrencies: [(code: String, symbol: String, name: String)] = [
        ("USD", "$", "US Dollar"),
        ("VND", "₫", "VN Dong")
    ]
    
    var currencySymbol: String {
        Self.availableCurrencies.first { $0.code == currencyCode }?.symbol ?? "$"
    }
    
    // MARK: - Initialization
    
    private init() {
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        self.userEmail = UserDefaults.standard.string(forKey: Keys.userEmail) ?? ""
        self.currencyCode = UserDefaults.standard.string(forKey: Keys.currencyCode) ?? "USD"
        self.appearanceMode = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: Keys.appearanceMode) ?? "") ?? .dark
        self.defaultCategoryId = UserDefaults.standard.string(forKey: Keys.defaultCategoryId)
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        self.budgetAlertThreshold = UserDefaults.standard.double(forKey: Keys.budgetAlertThreshold).nonZero ?? 0.9
    }
}

// MARK: - Double Extension

private extension Double {
    var nonZero: Double? {
        self == 0 ? nil : self
    }
}
