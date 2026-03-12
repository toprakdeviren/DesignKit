import SwiftUI

// MARK: - Platform Detection

public enum Platform {
    case iOS
    case macOS
    case tvOS
    case watchOS
    case visionOS
    case unknown
    
    public static var current: Platform {
        #if os(iOS)
        if #available(iOS 17.0, *), ProcessInfo.processInfo.isiOSAppOnMac {
            return .iOS
        }
        return .iOS
        #elseif os(macOS)
        return .macOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(visionOS)
        return .visionOS
        #else
        return .unknown
        #endif
    }
    
    public var isVisionOS: Bool {
        #if os(visionOS)
        return true
        #else
        return false
        #endif
    }
    
    public var isTvOS: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }
    
    public var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }
}

// MARK: - visionOS Optimizations

@available(visionOS 1.0, *)
public struct VisionOSOptimizations {
    
    /// Apply spatial effects to a view
    public static func spatialEffect<Content: View>(
        _ content: Content,
        depth: CGFloat = 20
    ) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// Add a hover effect for visionOS
    public static func hoverEffect<Content: View>(
        _ content: Content
    ) -> some View {
        #if os(visionOS)
        content.hoverEffect(.highlight)
        #else
        content
        #endif
    }
    
    /// Ornamental background for visionOS
    public static func ornamentalBackground<Content: View>(
        _ content: Content
    ) -> some View {
        content
            .background(.regularMaterial)
            .cornerRadius(24)
    }
}

// MARK: - tvOS Focus Management

#if os(tvOS)
@available(tvOS 16.0, *)
public struct TVOSFocusHelper {
    
    /// Enhanced focus border for tvOS
    public static func focusBorder<Content: View>(
        _ content: Content,
        isFocused: Bool
    ) -> some View {
        content
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isFocused ? 1.0 : 0), lineWidth: 4)
            )
            .shadow(color: .white.opacity(isFocused ? 0.5 : 0), radius: isFocused ? 20 : 0)
            .animation(AnimationTokens.micro, value: isFocused)
    }
    
    /// Button optimized for tvOS remote
    public static func remoteOptimizedButton<Content: View>(
        _ content: Content,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            content
                .frame(minWidth: 200, minHeight: 80)
        }
        .buttonStyle(.card)
    }
}
#endif

// MARK: - watchOS Layout Helpers

#if os(watchOS)
@available(watchOS 9.0, *)
public struct WatchOSLayoutHelper {
    
    /// Optimized list for watchOS
    public static func compactList<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        List {
            content()
        }
        .listStyle(.carousel)
    }
    
    /// Digital Crown rotatable view
    public static func crownRotatable<Content: View>(
        _ content: Content,
        value: Binding<Double>,
        in range: ClosedRange<Double>
    ) -> some View {
        content
            .digitalCrownRotation(value, from: range.lowerBound, through: range.upperBound)
    }
    
    /// Compact card for watchOS
    public static func compactCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding(8)
        .background(Color(. systemGray6))
        .cornerRadius(10)
    }
}
#endif

// MARK: - Platform-Specific View Modifiers

extension View {
    /// Apply platform-specific padding
    public func platformPadding() -> some View {
        #if os(tvOS)
        self.padding(40)
        #elseif os(watchOS)
        self.padding(8)
        #elseif os(visionOS)
        self.padding(24)
        #else
        self.padding(16)
        #endif
    }
    
    /// Platform-specific corner radius
    public func platformCornerRadius() -> some View {
        #if os(tvOS)
        self.cornerRadius(20)
        #elseif os(watchOS)
        self.cornerRadius(8)
        #elseif os(visionOS)
        self.cornerRadius(24)
        #else
        self.cornerRadius(12)
        #endif
    }
    
    /// Apply visionOS material if available
    @ViewBuilder
    public func visionOSMaterial() -> some View {
        #if os(visionOS)
        if #available(visionOS 1.0, *) {
            self.background(.ultraThinMaterial)
        } else {
            self
        }
        #else
        self
        #endif
    }
    
    /// Apply tvOS focus effect
    @ViewBuilder
    public func tvOSFocusEffect(isFocused: Bool = false) -> some View {
        #if os(tvOS)
        if #available(tvOS 16.0, *) {
            TVOSFocusHelper.focusBorder(self, isFocused: isFocused)
        } else {
            self
        }
        #else
        self
        #endif
    }
    
    /// Conditional watchOS styling
    @ViewBuilder
    public func watchOSCompact() -> some View {
        #if os(watchOS)
        self
            .font(.caption)
            .lineLimit(2)
        #else
        self
        #endif
    }
}

// MARK: - Platform-Specific Components

/// Platform-adaptive button
public struct DKPlatformButton: View {
    private let title: String
    private let action: () -> Void
    
    @FocusState private var isFocused: Bool
    @Environment(\.designKitTheme) private var theme
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(platformFont)
                .foregroundColor(.white)
                .frame(maxWidth: platformFrameWidth)
                .padding(platformPadding)
                .background(theme.colorTokens.primary500)
                .cornerRadius(platformCornerRadius)
        }
        #if os(tvOS)
        .buttonStyle(.card)
        .focused($isFocused)
        .tvOSFocusEffect(isFocused: isFocused)
        #else
        .buttonStyle(.plain)
        #endif
    }
    
    private var platformFont: Font {
        #if os(tvOS)
        return .title2
        #elseif os(watchOS)
        return .caption
        #elseif os(visionOS)
        return .title3
        #else
        return .body
        #endif
    }
    
    private var platformFrameWidth: CGFloat? {
        #if os(tvOS)
        return 400
        #elseif os(watchOS)
        return nil
        #else
        return nil
        #endif
    }
    
    private var platformPadding: CGFloat {
        #if os(tvOS)
        return 20
        #elseif os(watchOS)
        return 8
        #elseif os(visionOS)
        return 16
        #else
        return 12
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(tvOS)
        return 16
        #elseif os(watchOS)
        return 8
        #elseif os(visionOS)
        return 20
        #else
        return 12
        #endif
    }
}

/// Platform-adaptive card
public struct DKPlatformCard<Content: View>: View {
    private let content: () -> Content
    
    @Environment(\.designKitTheme) private var theme
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding(platformPadding)
            .background(platformBackground)
            .cornerRadius(platformCornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius)
    }
    
    private var platformPadding: CGFloat {
        #if os(tvOS)
        return 32
        #elseif os(watchOS)
        return 8
        #elseif os(visionOS)
        return 20
        #else
        return 16
        #endif
    }
    
    @ViewBuilder
    private var platformBackground: some View {
        #if os(visionOS)
        if #available(visionOS 1.0, *) {
            Color.clear.background(.regularMaterial)
        } else {
            theme.colorTokens.surface
        }
        #else
        theme.colorTokens.surface
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(tvOS)
        return 20
        #elseif os(watchOS)
        return 10
        #elseif os(visionOS)
        return 24
        #else
        return 12
        #endif
    }
    
    private var shadowColor: Color {
        #if os(visionOS)
        return .clear
        #else
        return .black.opacity(0.1)
        #endif
    }
    
    private var shadowRadius: CGFloat {
        #if os(tvOS)
        return 15
        #elseif os(watchOS)
        return 3
        #elseif os(visionOS)
        return 0
        #else
        return 8
        #endif
    }
}

// MARK: - Platform-Specific Spacing

public struct PlatformSpacing {
    public static var small: CGFloat {
        #if os(tvOS)
        return 16
        #elseif os(watchOS)
        return 4
        #elseif os(visionOS)
        return 12
        #else
        return 8
        #endif
    }
    
    public static var medium: CGFloat {
        #if os(tvOS)
        return 32
        #elseif os(watchOS)
        return 8
        #elseif os(visionOS)
        return 20
        #else
        return 16
        #endif
    }
    
    public static var large: CGFloat {
        #if os(tvOS)
        return 48
        #elseif os(watchOS)
        return 12
        #elseif os(visionOS)
        return 32
        #else
        return 24
        #endif
    }
}

