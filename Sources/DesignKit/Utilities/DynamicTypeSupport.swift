import SwiftUI

// MARK: - Dynamic Type Support
//
// DesignKit components use `@ScaledMetric` internally for sizes that
// should respond to the user's preferred text size. This file provides:
//
//   1. `DKScaledValue`        — @ScaledMetric wrapper with min/max clamp
//   2. `DKDynamicTypeModifier`— cap a subtree at a maximum content size
//   3. `View.dkLimitDynamicType(to:)` — prevents extreme scaling in compact UIs
//   4. `DKTypeScale`          — semantic font scale table matching Apple HIG
//   5. `DKDynamicTypePreview` — DEBUG helper to preview all Dynamic Type sizes

// MARK: - Scaled Value Wrapper

/// A type-safe wrapper around `@ScaledMetric` with optional clamping.
///
/// ```swift
/// @State private var iconSize = DKScaledValue(base: 24, min: 20, max: 40)
///
/// Image(systemName: "star")
///     .font(.system(size: iconSize.value))
/// ```
@MainActor
public struct DKScaledValue {
    private let base: CGFloat
    private let minimum: CGFloat?
    private let maximum: CGFloat?

    public init(base: CGFloat, min minimum: CGFloat? = nil, max maximum: CGFloat? = nil) {
        self.base = base
        self.minimum = minimum
        self.maximum = maximum
    }

    /// Returns the raw base value. In real usage, bind to @ScaledMetric in a View.
    public var baseValue: CGFloat { base }

    public func clamped(_ scaled: CGFloat) -> CGFloat {
        var v = scaled
        if let lo = minimum { v = Swift.max(lo, v) }
        if let hi = maximum { v = Swift.min(hi, v) }
        return v
    }
}

// MARK: - Dynamic Type Cap Modifier

/// Prevents a view subtree from scaling beyond a specified content size category.
///
/// Use on compact UI elements (avatars, icon buttons, badge chips) where
/// extreme "AX5" sizes would break the layout rather than help readability.
///
/// ```swift
/// DKAvatar(initials: "AB", size: .md)
///     .dkLimitDynamicType(to: .xxxLarge)
///
/// DKBadge("99", variant: .danger)
///     .dkLimitDynamicType(to: .accessibilityLarge)
/// ```
public struct DKDynamicTypeModifier: ViewModifier {
    let limit: ContentSizeCategory

    @Environment(\.sizeCategory) private var sizeCategory

    public func body(content: Content) -> some View {
        content
            .environment(\.sizeCategory, min(sizeCategory, limit))
    }
}

public extension View {
    /// Caps Dynamic Type scaling to `limit` for this view subtree.
    func dkLimitDynamicType(to limit: ContentSizeCategory = .extraExtraExtraLarge) -> some View {
        modifier(DKDynamicTypeModifier(limit: limit))
    }
}

// MARK: - ContentSizeCategory + Comparable

extension ContentSizeCategory: @retroactive Comparable {
    public static func < (lhs: ContentSizeCategory, rhs: ContentSizeCategory) -> Bool {
        lhs.index < rhs.index
    }

    private var index: Int {
        switch self {
        case .extraSmall:                       return 0
        case .small:                            return 1
        case .medium:                           return 2
        case .large:                            return 3
        case .extraLarge:                       return 4
        case .extraExtraLarge:                  return 5
        case .extraExtraExtraLarge:             return 6
        case .accessibilityMedium:              return 7
        case .accessibilityLarge:               return 8
        case .accessibilityExtraLarge:          return 9
        case .accessibilityExtraExtraLarge:     return 10
        case .accessibilityExtraExtraExtraLarge: return 11
        @unknown default:                       return 6
        }
    }
}

// MARK: - Semantic Type Scale

/// Semantic text styles mapped to Design Token sizes.
///
/// These track Apple's HIG type scale and should be used instead of hardcoded
/// font sizes so that Dynamic Type works automatically.
///
/// ```swift
/// Text("Hello").font(DKTypeScale.body.font)
/// ```
public enum DKTypeScale {
    case display
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption1
    case caption2

    /// The SwiftUI `Font` for this scale level.
    public var font: Font {
        switch self {
        case .display:      return .system(size: 34, weight: .bold)
        case .title1:       return .title
        case .title2:       return .title2
        case .title3:       return .title3
        case .headline:     return .headline
        case .body:         return .body
        case .callout:      return .callout
        case .subheadline:  return .subheadline
        case .footnote:     return .footnote
        case .caption1:     return .caption
        case .caption2:     return .system(size: 11)
        }
    }

    /// A hint for the maximum ContentSizeCategory this text level should scale to.
    /// Titles scale further; captions cap earlier.
    public var scalingCap: ContentSizeCategory {
        switch self {
        case .display, .title1, .title2:
            return .accessibilityExtraExtraExtraLarge
        case .title3, .headline, .body, .callout:
            return .accessibilityExtraExtraLarge
        case .subheadline, .footnote:
            return .accessibilityExtraLarge
        case .caption1, .caption2:
            return .accessibilityLarge
        }
    }
}

// MARK: - Dynamic Type View Modifier

/// Applies a `DKTypeScale` font and automatically caps scaling.
///
/// ```swift
/// Text("Username").dkFont(.subheadline)
/// ```
public extension View {
    func dkFont(_ scale: DKTypeScale) -> some View {
        self
            .font(scale.font)
            .dkLimitDynamicType(to: scale.scalingCap)
    }
}

// MARK: - Adaptive Layout Helpers

/// Returns `true` when the current size category is an Accessibility category
/// (the user selected one of the five AX sizes in Settings > Accessibility > Display).
public extension EnvironmentValues {
    var dkIsAccessibilitySize: Bool {
        switch sizeCategory {
        case .accessibilityMedium,
             .accessibilityLarge,
             .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge,
             .accessibilityExtraExtraExtraLarge:
            return true
        default:
            return false
        }
    }
}

/// Renders different layouts for standard vs. accessibility text sizes.
///
/// ```swift
/// DKAdaptiveStack(spacing: 12) {
///     avatar
///     Text(name)
/// }
/// // Standard:     avatar Text  (horizontal)
/// // Accessibility: avatar
/// //               Text         (vertical, larger targets)
/// ```
public struct DKAdaptiveStack<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    @Environment(\.sizeCategory) private var sizeCategory

    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if sizeCategory >= .accessibilityMedium {
            VStack(alignment: .leading, spacing: spacing) { content }
        } else {
            HStack(spacing: spacing) { content }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Dynamic Type") {
    struct DynamicTypeDemo: View {
        @State private var sizeCategory: ContentSizeCategory = .large

        private let sizes: [ContentSizeCategory] = [
            .small, .medium, .large, .extraLarge,
            .extraExtraLarge, .extraExtraExtraLarge,
            .accessibilityMedium, .accessibilityLarge
        ]

        private func label(for cat: ContentSizeCategory) -> String {
            switch cat {
            case .small: return "XS"
            case .medium: return "S"
            case .large: return "M (Default)"
            case .extraLarge: return "L"
            case .extraExtraLarge: return "XL"
            case .extraExtraExtraLarge: return "XXL"
            case .accessibilityMedium: return "AX1"
            case .accessibilityLarge: return "AX2"
            default: return "?"
            }
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Size category picker
                    Picker("Size", selection: $sizeCategory) {
                        ForEach(sizes, id: \.hashValue) { cat in
                            Text(label(for: cat)).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)

                    Divider()

                    // Type scale preview
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(
                            [DKTypeScale.display, .title1, .headline, .body, .callout, .subheadline, .footnote, .caption1],
                            id: \.font.hashValue
                        ) { scale in
                            Text(typeName(scale))
                                .dkFont(scale)
                        }
                    }

                    Divider()

                    // Adaptive stack
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DKAdaptiveStack").font(.caption).foregroundStyle(.secondary)
                        DKAdaptiveStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Alice Johnson").dkFont(.headline)
                                Text("alice@example.com").dkFont(.caption1)
                            }
                        }
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Capped element
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DKBadge — capped at AX Large").font(.caption).foregroundStyle(.secondary)
                        HStack {
                            DKBadge("99", variant: .danger)
                                .dkLimitDynamicType(to: .accessibilityLarge)
                            Text("Notification")
                        }
                    }
                }
                .padding(16)
            }
            .environment(\.sizeCategory, sizeCategory)
        }

        private func typeName(_ scale: DKTypeScale) -> String {
            switch scale {
            case .display:      return "Display — AaBbCcDd"
            case .title1:       return "Title 1 — AaBbCcDd"
            case .headline:     return "Headline — AaBbCcDd"
            case .body:         return "Body — AaBbCcDd"
            case .callout:      return "Callout — AaBbCcDd"
            case .subheadline:  return "Subheadline — AaBbCcDd"
            case .footnote:     return "Footnote — AaBbCcDd"
            case .caption1:     return "Caption 1 — AaBbCcDd"
            default:            return "Scale"
            }
        }
    }
    return DynamicTypeDemo()
}
#endif
