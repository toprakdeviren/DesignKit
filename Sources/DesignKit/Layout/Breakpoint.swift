import SwiftUI

/// Device breakpoints for responsive layouts
public enum Breakpoint: Comparable {
    case xs         // Extra small - watchOS, very small phones (<375px)
    case sm         // Small - iPhone SE, mini phones (375-640px)
    case md         // Medium - iPhone standard, narrow iPad split (640-768px)
    case lg         // Large - iPhone Plus/Max, iPad portrait (768-1024px)
    case xl         // Extra large - iPad landscape, small Mac (1024-1280px)
    case xxl        // 2X large - Mac, large displays (>1280px)
    
    /// Legacy aliases for compatibility
    public static let compact: Breakpoint = .sm
    public static let regular: Breakpoint = .md
    public static let large: Breakpoint = .xl
    
    /// Detect current breakpoint from horizontal size class and screen width
    public static func current(
        horizontalSizeClass: UserInterfaceSizeClass?,
        width: CGFloat
    ) -> Breakpoint {
        #if os(watchOS)
        return .xs
        #elseif os(tvOS)
        return .xxl
        #elseif os(macOS)
        if width > 1280 {
            return .xxl
        } else if width > 1024 {
            return .xl
        } else if width > 768 {
            return .lg
        } else {
            return .md
        }
        #elseif os(iOS)
        if horizontalSizeClass == .compact {
            if width < 375 {
                return .xs
            } else if width < 640 {
                return .sm
            } else {
                return .md
            }
        } else {
            if width > 1280 {
                return .xxl
            } else if width > 1024 {
                return .xl
            } else if width > 768 {
                return .lg
            } else {
                return .md
            }
        }
        #else
        return .md
        #endif
    }
    
    /// Max container width for each breakpoint
    public var maxContainerWidth: CGFloat? {
        switch self {
        case .xs: return nil        // Full width
        case .sm: return 640
        case .md: return 768
        case .lg: return 1024
        case .xl: return 1280
        case .xxl: return 1536
        }
    }
    
    /// Minimum width for this breakpoint
    public var minWidth: CGFloat {
        switch self {
        case .xs: return 0
        case .sm: return 375
        case .md: return 640
        case .lg: return 768
        case .xl: return 1024
        case .xxl: return 1280
        }
    }
}

// MARK: - Environment Key

private struct BreakpointEnvironmentKey: EnvironmentKey {
    static let defaultValue: Breakpoint = .regular
}

extension EnvironmentValues {
    /// Current breakpoint
    public var breakpoint: Breakpoint {
        get { self[BreakpointEnvironmentKey.self] }
        set { self[BreakpointEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Modifier

struct BreakpointModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .environment(
                    \.breakpoint,
                    Breakpoint.current(
                        horizontalSizeClass: horizontalSizeClass,
                        width: geometry.size.width
                    )
                )
        }
    }
}

extension View {
    /// Automatically detect and inject breakpoint into environment
    public func detectBreakpoint() -> some View {
        modifier(BreakpointModifier())
    }
}

