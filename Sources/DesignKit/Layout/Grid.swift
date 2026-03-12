import SwiftUI

/// A Bootstrap-inspired responsive grid system for SwiftUI
///
/// Usage:
/// ```swift
/// Grid {
///     Row {
///         Col(span: 6) { Text("Half") }
///         Col(span: 6) { Text("Half") }
///     }
///     Row {
///         Col(compact: 12, regular: 6, large: 4) {
///             Text("Responsive column")
///         }
///     }
/// }
/// ```
public struct Grid<Content: View>: View {
    
    private let spacing: CGFloat
    private let content: Content
    
    @Environment(\.breakpoint) private var breakpoint
    
    public init(
        spacing: DesignTokens.Spacing = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing.rawValue
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
    }
}

/// A horizontal row in the grid with proper column distribution
public struct Row<Content: View>: View {
    
    private let spacing: CGFloat
    private let content: Content
    
    @Environment(\.breakpoint) private var breakpoint
    
    public init(
        spacing: DesignTokens.Spacing = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing.rawValue
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: spacing) {
                content
                    .environment(\.rowWidth, geometry.size.width)
                    .environment(\.rowSpacing, spacing)
            }
        }
    }
}

/// Responsive column span configuration
public struct ColSpan {
    let compact: Int
    let regular: Int
    let large: Int
    
    public init(compact: Int = 12, regular: Int? = nil, large: Int? = nil) {
        self.compact = compact
        self.regular = regular ?? compact
        self.large = large ?? (regular ?? compact)
    }
    
    /// Get span for current breakpoint
    func span(for breakpoint: Breakpoint) -> Int {
        switch breakpoint {
        case .xs, .sm: return compact
        case .md, .lg: return regular
        case .xl, .xxl: return large
        }
    }
}

/// A column within a row with responsive breakpoint support
public struct Col<Content: View>: View {
    
    private let colSpan: ColSpan
    private let totalColumns: Int
    private let content: Content
    
    @Environment(\.breakpoint) private var breakpoint
    @Environment(\.rowWidth) private var rowWidth
    @Environment(\.rowSpacing) private var rowSpacing
    
    /// Returns a column with fixed span
    /// - Parameters:
    ///   - span: Number of columns to span (1-12)
    ///   - totalColumns: Total columns in the grid (default: 12)
    ///   - content: Column content
    public init(
        span: Int = 12,
        totalColumns: Int = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.colSpan = ColSpan(compact: span, regular: span, large: span)
        self.totalColumns = totalColumns
        self.content = content()
    }
    
    /// Returns a responsive column with breakpoint-specific spans
    /// - Parameters:
    ///   - compact: Span for compact screens (iPhone portrait)
    ///   - regular: Span for regular screens (iPhone landscape, iPad)
    ///   - large: Span for large screens (iPad landscape, Mac)
    ///   - totalColumns: Total columns in the grid (default: 12)
    ///   - content: Column content
    public init(
        compact: Int = 12,
        regular: Int? = nil,
        large: Int? = nil,
        totalColumns: Int = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.colSpan = ColSpan(compact: compact, regular: regular, large: large)
        self.totalColumns = totalColumns
        self.content = content()
    }
    
    public var body: some View {
        let currentSpan = colSpan.span(for: breakpoint)
        let clampedSpan = max(1, min(currentSpan, totalColumns))
        
        content
            .frame(width: columnWidth(span: clampedSpan))
            .frame(maxWidth: .infinity)
    }
    
    /// Calculate actual column width based on available row width
    private func columnWidth(span: Int) -> CGFloat? {
        guard let rowWidth = rowWidth, rowWidth > 0 else {
            return nil
        }
        
        // Calculate width considering spacing between columns
        let totalSpacing = CGFloat(totalColumns - 1) * rowSpacing
        let availableWidth = rowWidth - totalSpacing
        let columnWidth = availableWidth / CGFloat(totalColumns)
        
        return columnWidth * CGFloat(span) + (CGFloat(span - 1) * rowSpacing)
    }
}

// MARK: - Environment Keys

private struct RowWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

private struct RowSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

extension EnvironmentValues {
    var rowWidth: CGFloat? {
        get { self[RowWidthKey.self] }
        set { self[RowWidthKey.self] = newValue }
    }
    
    var rowSpacing: CGFloat {
        get { self[RowSpacingKey.self] }
        set { self[RowSpacingKey.self] = newValue }
    }
}

