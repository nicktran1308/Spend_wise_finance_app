import SwiftUI

// MARK: - Color Hex Extension

extension Color {
    /// Initialize Color from hex string (e.g., "#FF5733" or "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - App Color Palette

extension Color {
    /// App-specific colors
    static let appBackground = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#1C1C1E")
    static let secondaryBackground = Color(hex: "#2C2C2E")
    
    static let incomeGreen = Color(hex: "#34C759")
    static let expenseRed = Color(hex: "#FF6B6B")
    static let accentBlue = Color(hex: "#007AFF")
    
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#8E8E93")
}
