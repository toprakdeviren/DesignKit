import SwiftUI

// MARK: - macOS Catalyst Compatibility
//
// DesignKit targets iOS 16+ and macOS 13+ (via Catalyst and native Mac).
// This file provides:
//
//   1. `DKPlatform` — compile-time and runtime platform detection  
//   2. `View.dkiOSOnly()` / `.dkMacOnly()` — conditional visibility
//   3. `DKCatalystWindowAdaptor` — recommended window sizing for Catalyst
//   4. Cross-platform gesture reconciliation (tap vs click)
//   5. `DKHoverEffect` — pointer hover on macOS/Catalyst, no-op on iOS
//   6. `DKCursorModifier` — sets the pointer cursor on macOS
//   7. `DKScrollViewKeyboardDismiss` — platform-safe keyboard dismiss

// MARK: - Platform Detection

/// Compile-time and runtime platform constants.
public enum DKPlatform {
    /// `true` when compiled for iOS (including Catalyst on macOS).
    public static var isiOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }

    /// `true` when running as a Mac Catalyst app on macOS.
    public static var isCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

    /// `true` when running natively on macOS (not Catalyst).
    public static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    /// `true` when running on tvOS.
    public static var isTVOS: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }

    /// `true` when running on watchOS.
    public static var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }

    /// Human-readable name for the current platform.
    public static var name: String {
        if isCatalyst { return "macOS (Catalyst)" }
        if isMac      { return "macOS" }
        if isTVOS     { return "tvOS" }
        if isWatchOS  { return "watchOS" }
        return "iOS"
    }
}

// MARK: - Conditional Platform Visibility

public extension View {

    /// Hides the view on macOS and Catalyst.
    ///
    /// Use for UI elements that are touch-only (e.g. pull-to-refresh handles,
    /// haptic feedback triggers, swipe gesture instructional callouts).
    @ViewBuilder
    func dkiOSOnly() -> some View {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        self
        #else
        EmptyView()
        #endif
    }

    /// Hides the view on iOS; shows only on macOS (native or Catalyst).
    @ViewBuilder
    func dkMacOnly() -> some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        self
        #else
        EmptyView()
        #endif
    }

    /// Shows the view only when running as macOS Catalyst.
    @ViewBuilder
    func dkCatalystOnly() -> some View {
        #if targetEnvironment(macCatalyst)
        self
        #else
        EmptyView()
        #endif
    }
}

// MARK: - Hover Effect (Catalyst / macOS)

/// Adds a macOS/Catalyst pointer hover highlight.
/// On iOS this is a no-op so you can call it unconditionally.
///
/// ```swift
/// DKButton("Action", variant: .primary) { ... }
///     .dkHoverEffect()
/// ```
public extension View {
    @ViewBuilder
    func dkHoverEffect(_ style: HoverEffectStyle = .automatic) -> some View {
        #if os(iOS)
        self.hoverEffect(style.iosStyle)
        #else
        self  // macOS handles hover natively through ButtonStyle
        #endif
    }
}

public enum HoverEffectStyle {
    case automatic
    case highlight
    case lift

    #if os(iOS)
    var iosStyle: HoverEffect {
        switch self {
        case .automatic: return .automatic
        case .highlight: return .highlight
        case .lift:      return .lift
        }
    }
    #endif
}

// MARK: - Cursor Modifier (macOS native)

/// Sets the pointer cursor on macOS native builds.
/// No-op on iOS/Catalyst.
public extension View {
    @ViewBuilder
    func dkPointingCursor() -> some View {
        #if os(macOS)
        self.onHover { inside in
            if inside { NSCursor.pointingHand.push() }
            else      { NSCursor.pop() }
        }
        #else
        self
        #endif
    }
}

// MARK: - Keyboard Dismiss

/// Platform-safe scroll view keyboard dismiss mode.
///
/// On iOS 16+ uses `.scrollDismissesKeyboard(.interactively)`.
/// On macOS (no keyboard to dismiss) this is a no-op.
public extension View {
    @ViewBuilder
    func dkScrollKeyboardDismiss() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - Catalyst Window Sizing

/// Apply recommended minimum / ideal window sizes for Catalyst.
///
/// Call once on the root window scene or NavigationView.
///
/// ```swift
/// ContentView()
///     .dkCatalystWindowSize()
/// ```
public extension View {
    @ViewBuilder
    func dkCatalystWindowSize(
        minWidth: CGFloat = 700,
        idealWidth: CGFloat = 960,
        minHeight: CGFloat = 500,
        idealHeight: CGFloat = 700
    ) -> some View {
        #if targetEnvironment(macCatalyst)
        self
            .frame(minWidth: minWidth, idealWidth: idealWidth)
            .frame(minHeight: minHeight, idealHeight: idealHeight)
        #else
        self
        #endif
    }
}

// MARK: - Toolbar Customization Overrides
//
// Catalyst inherits iOS navigation bars and converts them to macOS toolbars.
// These helpers smooth over differences.

public extension View {

    /// Removes the navigation bar background tint that looks odd on macOS toolbars.
    @ViewBuilder
    func dkTransparentToolbarBackground() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - Touch/Click Unified Gesture

/// A tap/click gesture that works on all platforms.
///
/// On iOS: triggers on finger tap.
/// On macOS/Catalyst: also responds to trackpad clicks.
///
/// ```swift
/// Text("Tap me")
///     .dkTapGesture { handleTap() }
/// ```
public extension View {
    func dkTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        self.onTapGesture(count: count, perform: action)
    }
}

// MARK: - Platform-Adaptive List Style

public extension View {
    /// Uses `.insetGrouped` on iOS and `.sidebar` on macOS/Catalyst.
    @ViewBuilder
    func dkAdaptiveListStyle() -> some View {
        #if os(iOS)
        self.listStyle(.insetGrouped)
        #elseif os(macOS)
        self.listStyle(.sidebar)
        #else
        self.listStyle(.grouped)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Platform Compat") {
    NavigationStack {
        List {
            Section("Platform Detection") {
                LabeledContent("Current Platform", value: DKPlatform.name)
                LabeledContent("Is Catalyst", value: DKPlatform.isCatalyst ? "Yes" : "No")
                LabeledContent("Is macOS", value: DKPlatform.isMac ? "Yes" : "No")
            }

            Section("Conditional Visibility") {
                Text("iOS Only (hidden on macOS/Catalyst)")
                    .foregroundStyle(.blue)
                    .dkiOSOnly()

                Text("macOS Only (hidden on iOS)")
                    .foregroundStyle(.green)
                    .dkMacOnly()

                Text("Always visible")
                    .foregroundStyle(.primary)
            }

            Section("Hover Effect") {
                Button("Hover over me (macOS/iPadOS)") {}
                    .dkHoverEffect(.highlight)
                    .buttonStyle(.bordered)
            }
        }
        .dkAdaptiveListStyle()
        .navigationTitle("Platform Compat")
        .dkScrollKeyboardDismiss()
        .dkCatalystWindowSize()
    }
}
#endif
