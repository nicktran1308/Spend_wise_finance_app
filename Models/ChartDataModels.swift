//
//  ChartDataModels.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//
import Foundation

/// Data point for daily/monthly spending chart
struct DailySpend: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

/// Data point for category breakdown chart
struct CategorySpend: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
}
