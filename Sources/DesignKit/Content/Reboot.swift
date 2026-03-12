import SwiftUI

/// Reboot - Reset default iOS styling for consistency
///
/// Apply this modifier to the root view to normalize default styles
public struct RebootModifier: ViewModifier {
    
    public func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .listStyle(.plain)
            .textFieldStyle(.plain)
    }
}

extension View {
    /// Apply DesignKit reboot (style normalization)
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .reboot()
    /// ```
    public func reboot() -> some View {
        modifier(RebootModifier())
    }
}

