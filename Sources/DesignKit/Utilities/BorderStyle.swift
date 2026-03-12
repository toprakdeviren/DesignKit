import SwiftUI

/// Border style options
public enum BorderStyle {
    case soft
    case strong
    case primary
    case custom(Color, DesignTokens.BorderWidth)
}

private struct BorderStyleModifier: ViewModifier {
    let style: BorderStyle
    let cornerRadius: DesignTokens.Radius
    @Environment(\.designKitTheme) private var theme
    
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius.rawValue)
                .stroke(color, lineWidth: width)
        )
    }
    
    private var color: Color {
        let colors = theme.colorTokens
        switch style {
        case .soft: return colors.border
        case .strong: return colors.neutral400
        case .primary: return colors.primary500
        case .custom(let color, _): return color
        }
    }
    
    private var width: CGFloat {
        switch style {
        case .soft, .strong, .primary: return DesignTokens.BorderWidth.thin.rawValue
        case .custom(_, let width): return width.rawValue
        }
    }
}

extension View {
    /// Apply a border style
    ///
    /// Usage:
    /// ```swift
    /// Rectangle()
    ///     .borderStyle(.soft)
    /// ```
    public func borderStyle(
        _ style: BorderStyle,
        cornerRadius: DesignTokens.Radius = .none
    ) -> some View {
        self.modifier(BorderStyleModifier(style: style, cornerRadius: cornerRadius))
    }
}

