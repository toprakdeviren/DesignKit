import SwiftUI

/// Background style options
public enum BackgroundStyle {
    case surface
    case primary
    case secondary
    case neutral
    case custom(Color)
}

private struct BackgroundStyleModifier: ViewModifier {
    let style: BackgroundStyle
    @Environment(\.designKitTheme) private var theme
    
    func body(content: Content) -> some View {
        content.background(color)
    }
    
    private var color: Color {
        let colors = theme.colorTokens
        switch style {
        case .surface: return colors.surface
        case .primary: return colors.primary500
        case .secondary: return colors.neutral100
        case .neutral: return colors.neutral50
        case .custom(let color): return color
        }
    }
}

extension View {
    /// Apply a background style
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .backgroundStyle(.surface)
    /// ```
    public func backgroundStyle(_ style: BackgroundStyle) -> some View {
        self.modifier(BackgroundStyleModifier(style: style))
    }
}

