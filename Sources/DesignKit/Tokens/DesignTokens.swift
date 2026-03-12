import SwiftUI

/// Core design tokens defining spacing, radius, shadow, border, and opacity scales
public struct DesignTokens {
    
    // MARK: - Spacing Scale
    
    /// Spacing values for consistent layout
    public enum Spacing: CGFloat, CaseIterable {
        case xs = 4
        case sm = 8
        case md = 16
        case lg = 24
        case xl = 32
        case xxl = 48
        case xxxl = 64
    }
    
    // MARK: - Border Radius Scale
    
    /// Corner radius values
    public enum Radius: CGFloat, CaseIterable {
        case none = 0
        case sm = 4
        case md = 8
        case lg = 12
        case xl = 16
        case xxl = 24
        case full = 9999
    }
    
    // MARK: - Border Width Scale
    
    /// Border width values
    public enum BorderWidth: CGFloat, CaseIterable {
        case none = 0
        case thin = 1
        case regular = 2
        case thick = 4
    }
    
    // MARK: - Opacity Scale
    
    /// Opacity values for consistent transparency
    public enum Opacity: Double, CaseIterable {
        case transparent = 0.0
        case subtle = 0.1
        case light = 0.25
        case medium = 0.5
        case strong = 0.75
        case opaque = 1.0
    }
    
    // MARK: - Shadow Scale
    
    /// Shadow definitions for elevation
    public enum Shadow: String, CaseIterable {
        case none
        case sm
        case md
        case lg
        case xl
        
        public var radius: CGFloat {
            switch self {
            case .none: return 0
            case .sm: return 2
            case .md: return 4
            case .lg: return 8
            case .xl: return 16
            }
        }
        
        public var offset: CGSize {
            switch self {
            case .none: return .zero
            case .sm: return CGSize(width: 0, height: 1)
            case .md: return CGSize(width: 0, height: 2)
            case .lg: return CGSize(width: 0, height: 4)
            case .xl: return CGSize(width: 0, height: 8)
            }
        }
        
        public var opacity: Double {
            switch self {
            case .none: return 0
            case .sm: return 0.1
            case .md: return 0.15
            case .lg: return 0.2
            case .xl: return 0.25
            }
        }
    }
}

// MARK: - Convenience Extensions

extension CGFloat {
    /// Spacing token access via CGFloat
    public static let xs = DesignTokens.Spacing.xs.rawValue
    public static let sm = DesignTokens.Spacing.sm.rawValue
    public static let md = DesignTokens.Spacing.md.rawValue
    public static let lg = DesignTokens.Spacing.lg.rawValue
    public static let xl = DesignTokens.Spacing.xl.rawValue
    public static let xxl = DesignTokens.Spacing.xxl.rawValue
    public static let xxxl = DesignTokens.Spacing.xxxl.rawValue
}

