import Foundation

// MARK: - Double Extensions

extension Double {
    /// Formatted as currency string (e.g., "$1,234.56")
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    /// Formatted with sign (e.g., "+$100.00" or "-$50.00")
    func asCurrencyWithSign(isIncome: Bool) -> String {
        let sign = isIncome ? "+" : "-"
        return "\(sign)\(abs(self).asCurrency)"
    }
    
    /// Compact currency format (e.g., "$1.2K", "$3.5M")
    var asCompactCurrency: String {
        let absValue = abs(self)
        
        switch absValue {
        case 1_000_000...:
            return String(format: "$%.1fM", absValue / 1_000_000)
        case 1_000...:
            return String(format: "$%.1fK", absValue / 1_000)
        default:
            return asCurrency
        }
    }
    
    /// Percentage string (e.g., "75%")
    var asPercentage: String {
        String(format: "%.0f%%", self * 100)
    }
}
