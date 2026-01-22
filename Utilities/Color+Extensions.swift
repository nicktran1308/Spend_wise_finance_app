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
    /// App-specific adaptive colors that work in both light and dark modes
    
    // MARK: - Backgrounds
    static let appBackground = Color(UIColor.systemBackground)
    
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0) // #1C1C1E
                : UIColor.secondarySystemGroupedBackground
        })
    }
    
    static var secondaryBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0) // #2C2C2E
                : UIColor.tertiarySystemGroupedBackground
        })
    }
    
    // MARK: - Brand Colors
    static let incomeGreen = Color(hex: "#34C759")
    static let expenseRed = Color(hex: "#FF6B6B")
    static let accentBlue = Color(hex: "#007AFF")
    
    // MARK: - Text Colors
    static var textPrimary: Color {
        Color(UIColor.label)
    }
    
    static var textSecondary: Color {
        Color(UIColor.secondaryLabel)
    }
    
    // MARK: - Balance Card Gradient
    static var balanceGradientStart: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 30/255, green: 58/255, blue: 95/255, alpha: 1.0) // #1E3A5F
                : UIColor(red: 90/255, green: 150/255, blue: 220/255, alpha: 1.0) // Lighter blue
        })
    }
    
    static var balanceGradientEnd: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 13/255, green: 27/255, blue: 42/255, alpha: 1.0) // #0D1B2A
                : UIColor(red: 50/255, green: 100/255, blue: 180/255, alpha: 1.0) // Deeper blue
        })
    }
    
    // MARK: - Dividers & Borders
    static var dividerColor: Color {
        Color(UIColor.separator)
    }
    
    static var borderColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.1)
                : UIColor.black.withAlphaComponent(0.1)
        })
    }
}
