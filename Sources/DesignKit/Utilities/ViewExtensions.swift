import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Apply a transform conditionally
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .if(condition) { view in
    ///         view.bold()
    ///     }
    /// ```
    @ViewBuilder
    public func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply one of two transforms based on condition
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then: (Self) -> TrueContent,
        else: (Self) -> FalseContent
    ) -> some View {
        if condition {
            then(self)
        } else {
            `else`(self)
        }
    }
}

// MARK: - Layout Helpers

extension View {
    /// Horizontal stack helper
    public func horizontalStack(alignment: VerticalAlignment = .center, spacing: CGFloat = 8) -> some View {
        HStack(alignment: alignment, spacing: spacing) {
            self
        }
    }
    
    /// Vertical stack helper
    public func verticalStack(alignment: HorizontalAlignment = .center, spacing: CGFloat = 8) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            self
        }
    }
}

// MARK: - Padding Helpers

extension View {
    /// Apply padding using design tokens
    public func padding(_ spacing: DesignTokens.Spacing, _ edges: Edge.Set = .all) -> some View {
        self.padding(edges, spacing.rawValue)
    }
    
    // MARK: - Tailwind-style Utilities
    
    /// Apply padding to all edges (Tailwind: p-)
    public func p(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(spacing.rawValue)
    }
    
    /// Apply horizontal padding (Tailwind: px-)
    public func px(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.horizontal, spacing.rawValue)
    }
    
    /// Apply vertical padding (Tailwind: py-)
    public func py(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.vertical, spacing.rawValue)
    }
    
    /// Apply top padding (Tailwind: pt-)
    public func pt(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.top, spacing.rawValue)
    }
    
    /// Apply bottom padding (Tailwind: pb-)
    public func pb(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.bottom, spacing.rawValue)
    }
    
    /// Apply leading padding (Tailwind: pl-)
    public func pl(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.leading, spacing.rawValue)
    }
    
    /// Apply trailing padding (Tailwind: pr-)
    public func pr(_ spacing: DesignTokens.Spacing) -> some View {
        self.padding(.trailing, spacing.rawValue)
    }
}

// MARK: - Tailwind-style Utilities (continued)

extension View {
    /// Apply corner radius using design tokens (Tailwind: rounded-)
    public func rounded(_ radius: DesignTokens.Radius) -> some View {
        self.cornerRadius(radius.rawValue)
    }
    
    /// Apply opacity using design tokens
    public func opacity(_ opacity: DesignTokens.Opacity) -> some View {
        self.opacity(opacity.rawValue)
    }
}

// MARK: - Vertical Divider

extension View {
    /// Add a vertical rule/divider
    public func verticalRule(color: Color? = nil, width: CGFloat = 1) -> some View {
        VerticalRuleView(color: color, width: width)
    }
}

private struct VerticalRuleView: View {
    let color: Color?
    let width: CGFloat
    @Environment(\.designKitTheme) private var theme
    
    var body: some View {
        Rectangle()
            .fill(color ?? theme.colorTokens.border)
            .frame(width: width)
    }
}

