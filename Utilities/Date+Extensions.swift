import Foundation

// MARK: - Date Extensions

extension Date {
    /// Start of current month
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    /// End of current month
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }
    
    /// Start of current week
    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    /// Check if date is in current month
    var isInCurrentMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if date is in current week
    var isInCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Formatted string for display
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    /// Short month name (e.g., "Jan")
    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
    
    /// Day of week abbreviation (e.g., "Mon")
    var dayOfWeekShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
}

// MARK: - Calendar Helpers

extension Calendar {
    /// Get all dates in current month
    func datesInCurrentMonth() -> [Date] {
        let now = Date()
        let range = self.range(of: .day, in: .month, for: now)!
        let startOfMonth = now.startOfMonth
        
        return range.compactMap { day -> Date? in
            self.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    /// Get dates for last N days
    func datesForLastDays(_ count: Int) -> [Date] {
        (0..<count).compactMap { offset in
            self.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }
}
