import SwiftUI

// MARK: - RTL Support
//
// Right-to-Left language support for Arabic, Hebrew, Persian, Urdu, etc.
//
// DesignKit components automatically respect SwiftUI's layout direction
// (`LayoutDirection.rightToLeft`) via the `@Environment(\.layoutDirection)`
// key. This file provides:
//
//   1. `DKDirectionalPadding` — edge-aware padding (leading/trailing flip in RTL)
//   2. `DKDirectionalHStack`  — HStack that auto-reverses in RTL
//   3. `View.dkFlippedInRTL()` — scaleEffect(-1, 1) for non-semantic icons
//   4. `View.dkLeadingPadding()` / `.dkTrailingPadding()` — semantic shortcuts
//   5. `DKRTLEnvironment`      — DEBUG preview helper to preview RTL layouts

// MARK: - Layout Direction Environment Key

extension EnvironmentValues {
    /// The current layout direction (LTR or RTL), respecting OS locale.
    public var dkIsRTL: Bool {
        layoutDirection == .rightToLeft
    }
}

// MARK: - Directional HStack

/// An HStack that reverses its children's order in RTL layouts.
///
/// Use this instead of a plain HStack whenever the leading/trailing
/// semantic matters (e.g. icon + label should be label + icon in Arabic).
///
/// ```swift
/// DKDirectionalHStack(spacing: 8) {
///     Image(systemName: "person")
///     Text(username)
/// }
/// // In RTL:  Text  Image
/// // In LTR:  Image Text
/// ```
public struct DKDirectionalHStack<Content: View>: View {
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: Content

    @Environment(\.layoutDirection) private var direction

    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content
        }
        .environment(\.layoutDirection, direction == .rightToLeft ? .rightToLeft : .leftToRight)
        .flipsForRightToLeftLayoutDirection(true)
    }
}

// MARK: - RTL-Aware View Modifiers

public extension View {

    /// Flips the view horizontally in RTL layouts.
    /// Use for directional icons (arrows, chevrons, progress indicators).
    ///
    /// ```swift
    /// Image(systemName: "chevron.right")
    ///     .dkFlippedInRTL()
    /// // Shows "chevron.left" visually in Arabic/Hebrew
    /// ```
    func dkFlippedInRTL() -> some View {
        modifier(RTLFlipModifier())
    }

    /// Applies leading padding that respects layout direction.
    func dkLeadingPadding(_ value: CGFloat = 16) -> some View {
        modifier(DirectionalPaddingModifier(edge: .leading, value: value))
    }

    /// Applies trailing padding that respects layout direction.
    func dkTrailingPadding(_ value: CGFloat = 16) -> some View {
        modifier(DirectionalPaddingModifier(edge: .trailing, value: value))
    }

    /// Applies horizontal padding with independent leading/trailing values.
    func dkDirectionalPadding(leading: CGFloat = 0, trailing: CGFloat = 0) -> some View {
        modifier(DirectionalEdgePaddingModifier(leading: leading, trailing: trailing))
    }

    /// Sets text alignment based on layout direction.
    /// `.natural` maps to `.leading` in LTR and `.trailing` in RTL.
    func dkNaturalAlignment() -> some View {
        modifier(NaturalAlignmentModifier())
    }
}

// MARK: - RTL Flip Modifier

private struct RTLFlipModifier: ViewModifier {
    @Environment(\.layoutDirection) private var direction

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: direction == .rightToLeft ? -1 : 1, y: 1)
    }
}

// MARK: - Directional Padding Modifiers

private struct DirectionalPaddingModifier: ViewModifier {
    enum Edge { case leading, trailing }
    let edge: Edge
    let value: CGFloat

    @Environment(\.layoutDirection) private var direction

    func body(content: Content) -> some View {
        content.padding(resolvedEdge, value)
    }

    private var resolvedEdge: SwiftUI.Edge.Set {
        switch edge {
        case .leading:
            return direction == .rightToLeft ? .trailing : .leading
        case .trailing:
            return direction == .rightToLeft ? .leading : .trailing
        }
    }
}

private struct DirectionalEdgePaddingModifier: ViewModifier {
    let leading: CGFloat
    let trailing: CGFloat

    @Environment(\.layoutDirection) private var direction

    func body(content: Content) -> some View {
        if direction == .rightToLeft {
            content
                .padding(.leading, trailing)
                .padding(.trailing, leading)
        } else {
            content
                .padding(.leading, leading)
                .padding(.trailing, trailing)
        }
    }
}

private struct NaturalAlignmentModifier: ViewModifier {
    @Environment(\.layoutDirection) private var direction

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(direction == .rightToLeft ? .trailing : .leading)
    }
}

// MARK: - DKRTLEnvironment (DEBUG preview helper)

/// A DEBUG-only view modifier that forces RTL layout for preview purposes.
///
/// ```swift
/// #Preview("Arabic RTL") {
///     MyView()
///         .dkPreviewRTL()
/// }
/// ```
public extension View {
    func dkPreviewRTL(_ enabled: Bool = true) -> some View {
        environment(\.layoutDirection, enabled ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Semantic Layout Guide

/// Utility for building RTL-safe layouts imperatively.
///
/// ```swift
/// let insets = DKDirectionalInsets(leading: 16, trailing: 8, isRTL: env.dkIsRTL)
/// // Apply insets.left / insets.right to UIKit frames
/// ```
public struct DKDirectionalInsets {
    public let left: CGFloat
    public let right: CGFloat
    public let top: CGFloat
    public let bottom: CGFloat

    public init(
        leading: CGFloat = 0,
        trailing: CGFloat = 0,
        top: CGFloat = 0,
        bottom: CGFloat = 0,
        isRTL: Bool = false
    ) {
        self.left   = isRTL ? trailing : leading
        self.right  = isRTL ? leading  : trailing
        self.top    = top
        self.bottom = bottom
    }
}

// MARK: - RTL-Aware Component Overrides
//
// Components that need explicit RTL handling beyond automatic flipping.

public extension DKActivityIndicator {

    /// Builds a streaming indicator that sweeps right-to-left in RTL.
    static func streamingRTLSafe(color: Color? = nil) -> some View {
        DKActivityIndicator(style: .streaming, color: color)
            .dkFlippedInRTL()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("RTL Support") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {

            // LTR
            VStack(alignment: .leading, spacing: 8) {
                Text("LTR (English)").font(.caption).foregroundStyle(.secondary)
                DKDirectionalHStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .frame(width: 36, height: 36)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alice Johnson").font(.headline)
                        Text("alice@example.com").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").dkFlippedInRTL()
                }
                .padding(12)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(10)
            }

            // RTL simulation
            VStack(alignment: .trailing, spacing: 8) {
                Text("RTL (عربي)").font(.caption).foregroundStyle(.secondary)
                DKDirectionalHStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .frame(width: 36, height: 36)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("أليس جونسون").font(.headline)
                        Text("alice@example.com").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").dkFlippedInRTL()
                }
                .padding(12)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(10)
                .dkPreviewRTL()
            }

            // Growing text field RTL
            VStack(alignment: .leading, spacing: 8) {
                Text("Growing TextField in RTL").font(.caption).foregroundStyle(.secondary)
                DKGrowingTextField(text: .constant("مرحبا بالعالم"), placeholder: "اكتب رسالة…", maxLines: 3)
                    .dkPreviewRTL()
            }

            // Directional padding demo
            VStack(alignment: .leading, spacing: 8) {
                Text("dkLeadingPadding / dkTrailingPadding").font(.caption).foregroundStyle(.secondary)
                Text("Leading padded text")
                    .dkLeadingPadding(24)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(6)
                Text("Leading padded text (RTL)")
                    .dkLeadingPadding(24)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(6)
                    .dkPreviewRTL()
            }
        }
        .padding(16)
    }
}
#endif
