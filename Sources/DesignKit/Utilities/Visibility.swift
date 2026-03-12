import SwiftUI

extension View {
    /// Control visibility with opacity, hit-testing, and accessibility
    ///
    /// Usage:
    /// ```swift
    /// Text("Hidden")
    ///     .visible(false)
    /// ```
    public func visible(_ isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .accessibilityHidden(!isVisible)
    }
    
    /// Visually hidden but accessible to screen readers
    ///
    /// Useful for adding context for assistive technologies while keeping UI clean
    public func visuallyHidden() -> some View {
        self
            .frame(width: 0, height: 0)
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityHidden(false)
    }
    
    /// Completely hidden from both visual and accessibility tree
    public func fullyHidden() -> some View {
        self
            .frame(width: 0, height: 0)
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

