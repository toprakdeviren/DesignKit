import SwiftUI

// MARK: - Text Style Modifier

extension View {
    /// Apply a typography style to text with Dynamic Type support
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .textStyle(.headline)
    /// ```
    public func textStyle(_ style: TypographyTokens.TextStyle) -> some View {
        self.modifier(TextStyleModifier(style: style))
    }
    
    /// Apply a typography style with custom color
    public func textStyle(_ style: TypographyTokens.TextStyle, color: Color) -> some View {
        self.modifier(TextStyleModifier(style: style))
            .foregroundColor(color)
    }
}

private struct TextStyleModifier: ViewModifier {
    let style: TypographyTokens.TextStyle
    
    @ScaledMetric private var scaledSize: CGFloat
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(style: TypographyTokens.TextStyle) {
        self.style = style
        self._scaledSize = ScaledMetric(wrappedValue: style.size)
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: scaledSize, weight: style.weight))
            .lineSpacing(lineSpacing)
    }
    
    /// Calculate proper line spacing based on scaled size
    private var lineSpacing: CGFloat {
        let scaledLineHeight = style.lineHeight * (scaledSize / style.size)
        return max(0, scaledLineHeight - scaledSize)
    }
}

// MARK: - Text Truncation

extension View {
    /// Truncate text with line limit
    public func truncate(lines: Int = 1) -> some View {
        self
            .lineLimit(lines)
            .truncationMode(.tail)
    }
}

// MARK: - Custom Text Components

/// A text component with built-in typography style
public struct StyledText: View {
    
    private let text: String
    private let style: TypographyTokens.TextStyle
    private let color: Color?
    
    public init(
        _ text: String,
        style: TypographyTokens.TextStyle,
        color: Color? = nil
    ) {
        self.text = text
        self.style = style
        self.color = color
    }
    
    public var body: some View {
        Text(text)
            .textStyle(style)
            .foregroundColor(color)
    }
}

// MARK: - Link Style

extension View {
    /// Apply link styling to text
    public func linkStyle() -> some View {
        LinkStyleModifier(content: self)
    }
}

private struct LinkStyleModifier<Content: View>: View {
    let content: Content
    @Environment(\.designKitTheme) private var theme
    
    var body: some View {
        content
            .foregroundColor(theme.colorTokens.primary500)
            .underline()
    }
}

/// A clickable link component
public struct DKLink: View {
    
    private let text: String
    private let action: () -> Void
    
    @Environment(\.designKitTheme) private var theme
    
    public init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(text)
                .linkStyle()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - Code Style

extension View {
    /// Apply code block styling
    public func codeStyle() -> some View {
        CodeStyleModifier(content: self)
    }
}

private struct CodeStyleModifier<Content: View>: View {
    let content: Content
    @Environment(\.designKitTheme) private var theme
    
    var body: some View {
        content
            .font(.system(.body, design: .monospaced))
            .p(.sm)
            .background(theme.colorTokens.neutral100)
            .rounded(.sm)
    }
}

/// Inline code component
public struct DKInlineCode: View {
    
    private let text: String
    
    @Environment(\.designKitTheme) private var theme
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(theme.colorTokens.danger500)
            .px(DesignTokens.Spacing.xs)
            .background(theme.colorTokens.danger50)
            .rounded(.sm)
    }
}

// MARK: - List Styles

/// Bullet list item
public struct DKListItem: View {
    
    private let text: String
    private let level: Int
    
    @Environment(\.designKitTheme) private var theme
    
    public init(_ text: String, level: Int = 0) {
        self.text = text
        self.level = level
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .textStyle(.body)
                .foregroundColor(theme.colorTokens.textSecondary)
            
            Text(text)
                .textStyle(.body)
        }
        .padding(.leading, CGFloat(level) * 20)
    }
}

/// Ordered list item
public struct DKOrderedListItem: View {
    
    private let text: String
    private let number: Int
    private let level: Int
    
    @Environment(\.designKitTheme) private var theme
    
    public init(_ text: String, number: Int, level: Int = 0) {
        self.text = text
        self.number = number
        self.level = level
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .textStyle(.body)
                .foregroundColor(theme.colorTokens.textSecondary)
                .frame(width: 24, alignment: .trailing)
            
            Text(text)
                .textStyle(.body)
        }
        .padding(.leading, CGFloat(level) * 20)
    }
}

// MARK: - Text Formatting

extension View {
    /// Apply leading (line height multiplier)
    public func leading(_ multiplier: CGFloat) -> some View {
        self.lineSpacing(multiplier * 4) // Approximate line height adjustment
    }
    
    /// Apply tracking (letter spacing)
    public func tracking(_ spacing: CGFloat) -> some View {
        self.kerning(spacing)
    }
}

