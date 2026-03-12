import SwiftUI

/// Color tokens with light/dark mode support
public struct ColorTokens {
    
    // MARK: - Neutral Scale
    
    public static let neutral50 = Color("Neutral50", bundle: nil, light: "#fafafa", dark: "#0a0a0a")
    public static let neutral100 = Color("Neutral100", bundle: nil, light: "#f5f5f5", dark: "#171717")
    public static let neutral200 = Color("Neutral200", bundle: nil, light: "#e5e5e5", dark: "#262626")
    public static let neutral300 = Color("Neutral300", bundle: nil, light: "#d4d4d4", dark: "#404040")
    public static let neutral400 = Color("Neutral400", bundle: nil, light: "#a3a3a3", dark: "#525252")
    public static let neutral500 = Color("Neutral500", bundle: nil, light: "#737373", dark: "#737373")
    public static let neutral600 = Color("Neutral600", bundle: nil, light: "#525252", dark: "#a3a3a3")
    public static let neutral700 = Color("Neutral700", bundle: nil, light: "#404040", dark: "#d4d4d4")
    public static let neutral800 = Color("Neutral800", bundle: nil, light: "#262626", dark: "#e5e5e5")
    public static let neutral900 = Color("Neutral900", bundle: nil, light: "#171717", dark: "#f5f5f5")
    public static let neutral950 = Color("Neutral950", bundle: nil, light: "#0a0a0a", dark: "#fafafa")
    
    // MARK: - Primary Scale
    
    public static let primary50 = Color("Primary50", bundle: nil, light: "#eff6ff", dark: "#172554")
    public static let primary100 = Color("Primary100", bundle: nil, light: "#dbeafe", dark: "#1e3a8a")
    public static let primary200 = Color("Primary200", bundle: nil, light: "#bfdbfe", dark: "#1e40af")
    public static let primary300 = Color("Primary300", bundle: nil, light: "#93c5fd", dark: "#1d4ed8")
    public static let primary400 = Color("Primary400", bundle: nil, light: "#60a5fa", dark: "#2563eb")
    public static let primary500 = Color("Primary500", bundle: nil, light: "#3b82f6", dark: "#3b82f6")
    public static let primary600 = Color("Primary600", bundle: nil, light: "#2563eb", dark: "#60a5fa")
    public static let primary700 = Color("Primary700", bundle: nil, light: "#1d4ed8", dark: "#93c5fd")
    public static let primary800 = Color("Primary800", bundle: nil, light: "#1e40af", dark: "#bfdbfe")
    public static let primary900 = Color("Primary900", bundle: nil, light: "#1e3a8a", dark: "#dbeafe")
    
    // MARK: - Success Scale (Complete)
    
    public static let success50 = Color("Success50", bundle: nil, light: "#f0fdf4", dark: "#14532d")
    public static let success100 = Color("Success100", bundle: nil, light: "#dcfce7", dark: "#166534")
    public static let success200 = Color("Success200", bundle: nil, light: "#bbf7d0", dark: "#15803d")
    public static let success300 = Color("Success300", bundle: nil, light: "#86efac", dark: "#16a34a")
    public static let success400 = Color("Success400", bundle: nil, light: "#4ade80", dark: "#22c55e")
    public static let success500 = Color("Success500", bundle: nil, light: "#22c55e", dark: "#22c55e")
    public static let success600 = Color("Success600", bundle: nil, light: "#16a34a", dark: "#4ade80")
    public static let success700 = Color("Success700", bundle: nil, light: "#15803d", dark: "#86efac")
    public static let success800 = Color("Success800", bundle: nil, light: "#166534", dark: "#bbf7d0")
    public static let success900 = Color("Success900", bundle: nil, light: "#14532d", dark: "#dcfce7")
    
    // MARK: - Warning Scale (Complete)
    
    public static let warning50 = Color("Warning50", bundle: nil, light: "#fffbeb", dark: "#451a03")
    public static let warning100 = Color("Warning100", bundle: nil, light: "#fef3c7", dark: "#78350f")
    public static let warning200 = Color("Warning200", bundle: nil, light: "#fde68a", dark: "#92400e")
    public static let warning300 = Color("Warning300", bundle: nil, light: "#fcd34d", dark: "#b45309")
    public static let warning400 = Color("Warning400", bundle: nil, light: "#fbbf24", dark: "#d97706")
    public static let warning500 = Color("Warning500", bundle: nil, light: "#f59e0b", dark: "#f59e0b")
    public static let warning600 = Color("Warning600", bundle: nil, light: "#d97706", dark: "#fbbf24")
    public static let warning700 = Color("Warning700", bundle: nil, light: "#b45309", dark: "#fcd34d")
    public static let warning800 = Color("Warning800", bundle: nil, light: "#92400e", dark: "#fde68a")
    public static let warning900 = Color("Warning900", bundle: nil, light: "#78350f", dark: "#fef3c7")
    
    // MARK: - Danger Scale (Complete)
    
    public static let danger50 = Color("Danger50", bundle: nil, light: "#fef2f2", dark: "#450a0a")
    public static let danger100 = Color("Danger100", bundle: nil, light: "#fee2e2", dark: "#7f1d1d")
    public static let danger200 = Color("Danger200", bundle: nil, light: "#fecaca", dark: "#991b1b")
    public static let danger300 = Color("Danger300", bundle: nil, light: "#fca5a5", dark: "#b91c1c")
    public static let danger400 = Color("Danger400", bundle: nil, light: "#f87171", dark: "#dc2626")
    public static let danger500 = Color("Danger500", bundle: nil, light: "#ef4444", dark: "#ef4444")
    public static let danger600 = Color("Danger600", bundle: nil, light: "#dc2626", dark: "#f87171")
    public static let danger700 = Color("Danger700", bundle: nil, light: "#b91c1c", dark: "#fca5a5")
    public static let danger800 = Color("Danger800", bundle: nil, light: "#991b1b", dark: "#fecaca")
    public static let danger900 = Color("Danger900", bundle: nil, light: "#7f1d1d", dark: "#fee2e2")
    
    // MARK: - Info Scale (New)
    
    public static let info50 = Color("Info50", bundle: nil, light: "#f0f9ff", dark: "#082f49")
    public static let info100 = Color("Info100", bundle: nil, light: "#e0f2fe", dark: "#0c4a6e")
    public static let info200 = Color("Info200", bundle: nil, light: "#bae6fd", dark: "#075985")
    public static let info300 = Color("Info300", bundle: nil, light: "#7dd3fc", dark: "#0369a1")
    public static let info400 = Color("Info400", bundle: nil, light: "#38bdf8", dark: "#0284c7")
    public static let info500 = Color("Info500", bundle: nil, light: "#0ea5e9", dark: "#0ea5e9")
    public static let info600 = Color("Info600", bundle: nil, light: "#0284c7", dark: "#38bdf8")
    public static let info700 = Color("Info700", bundle: nil, light: "#0369a1", dark: "#7dd3fc")
    public static let info800 = Color("Info800", bundle: nil, light: "#075985", dark: "#bae6fd")
    public static let info900 = Color("Info900", bundle: nil, light: "#0c4a6e", dark: "#e0f2fe")
    
    // MARK: - Semantic Colors
    
    public static let background = neutral50
    public static let surface = Color("Surface", bundle: nil, light: Color(hex: "#ffffff").opacity(0.95), dark: Color(hex: "#1a1a1a").opacity(0.95))
    public static let border = neutral200
    public static let textPrimary = neutral900
    public static let textSecondary = neutral600
    public static let textTertiary = neutral400
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(_ name: String, bundle: Bundle?, light: String, dark: String) {
        self.init(name, bundle: bundle, light: Color(hex: light), dark: Color(hex: dark))
    }
    
    init(_ name: String, bundle: Bundle?, light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: name) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
        #else
        self = light
        #endif
    }
    
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
}

