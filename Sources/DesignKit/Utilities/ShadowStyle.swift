import SwiftUI

extension View {
    /// Apply a shadow using design tokens
    ///
    /// Usage:
    /// ```swift
    /// Card()
    ///     .shadow(.md)
    /// ```
    public func shadow(_ shadow: DesignTokens.Shadow, color: Color = .black) -> some View {
        self.shadow(
            color: color.opacity(shadow.opacity),
            radius: shadow.radius,
            x: shadow.offset.width,
            y: shadow.offset.height
        )
    }
}

