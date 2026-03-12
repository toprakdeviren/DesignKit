import SwiftUI

// MARK: - Swipe Action

/// A single action revealed when the user swipes a row.
public struct DKSwipeAction {
    public let icon: String
    public let label: String
    public let tint: Color
    public let style: Style
    public let action: () -> Void

    public enum Style {
        /// Normal width — shows icon + label side by side.
        case normal
        /// Fills the entire revealed area when swiped far enough (destructive confirm).
        case fill
        /// `fill` visuals with a red tint shorthand.
        case destructive
    }

    public init(
        icon: String,
        label: String,
        tint: Color,
        style: Style = .normal,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.tint = tint
        self.style = style
        self.action = action
    }
}

// MARK: - Swipeable Row

/// A container that reveals swipe actions on leading and/or trailing edges.
///
/// Works with any content — use it as a drop-in replacement for `HStack` in lists.
///
/// ```swift
/// DKSwipeableRow(
///     trailingActions: [
///         DKSwipeAction(icon: "trash", label: "Delete", tint: .red, style: .destructive) {
///             deleteItem()
///         },
///         DKSwipeAction(icon: "bell.slash", label: "Mute", tint: .gray) {
///             muteItem()
///         }
///     ]
/// ) {
///     ConversationRowView(conversation)
/// }
/// ```
public struct DKSwipeableRow<Content: View>: View {

    // MARK: Properties

    private let content: Content
    private let leadingActions: [DKSwipeAction]
    private let trailingActions: [DKSwipeAction]
    private let actionWidth: CGFloat

    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    #if os(iOS)
    private let haptic = UIImpactFeedbackGenerator(style: .rigid)
    #endif

    // MARK: Constants

    private var maxLeadingReveal: CGFloat { CGFloat(leadingActions.count) * actionWidth }
    private var maxTrailingReveal: CGFloat { CGFloat(trailingActions.count) * actionWidth }

    // MARK: Init

    public init(
        leadingActions: [DKSwipeAction] = [],
        trailingActions: [DKSwipeAction] = [],
        actionWidth: CGFloat = 80,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.actionWidth = actionWidth
    }

    // MARK: Body

    public var body: some View {
        ZStack {
            // Leading action strip (left side)
            if !leadingActions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(leadingActions.indices, id: \.self) { idx in
                        actionButton(leadingActions[idx], revealed: offset)
                            .frame(width: actionWidth)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }

            // Trailing action strip (right side)
            if !trailingActions.isEmpty {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(trailingActions.indices, id: \.self) { idx in
                        actionButton(trailingActions[idx], revealed: -offset)
                            .frame(width: actionButtonWidth(for: idx, side: trailingActions))
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Main content
            content
                .offset(x: offset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            isDragging = true
                            let proposed = value.translation.width

                            // Rubber-band resistance beyond max reveal
                            if proposed > 0 && leadingActions.isEmpty { return }
                            if proposed < 0 && trailingActions.isEmpty { return }

                            let limit = proposed > 0 ? maxLeadingReveal : maxTrailingReveal
                            let overflow = max(0, abs(proposed) - limit)
                            let damped = proposed > 0
                                ? min(proposed, limit + overflow * 0.25)
                                : max(proposed, -(limit + overflow * 0.25))
                            offset = damped
                        }
                        .onEnded { value in
                            isDragging = false
                            snapOrClose(translation: value.translation.width)
                        }
                )
                .animation(isDragging ? nil : AnimationTokens.transition, value: offset)
        }
        .clipped()
    }

    // MARK: - Action Button

    @ViewBuilder
    private func actionButton(_ action: DKSwipeAction, revealed: CGFloat) -> some View {
        let isFullFill = (action.style == .fill || action.style == .destructive)
            && revealed > actionWidth * 1.5

        Button {
            action.action()
            withAnimation(AnimationTokens.dismiss) { offset = 0 }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: action.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(action.label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(isFullFill ? action.tint : action.tint.opacity(0.9))
        .animation(AnimationTokens.micro, value: isFullFill)
    }

    /// Trailing action width — last action expands to fill overflow drag distance.
    private func actionButtonWidth(for index: Int, side: [DKSwipeAction]) -> CGFloat {
        let isLast = index == side.count - 1
        let baseReveal = -offset
        let overflow = max(0, baseReveal - maxTrailingReveal)
        return isLast ? actionWidth + overflow : actionWidth
    }

    private func triggerHaptic() {
        #if os(iOS)
        haptic.impactOccurred()
        #endif
    }

    // MARK: - Snap Logic

    private func snapOrClose(translation: CGFloat) {
        let threshold: CGFloat = 0.35

        if translation > 0 {
            // Swiped right — snap to leading reveal or close
            if offset > maxLeadingReveal * threshold {
                // Full reveal: trigger action automatically if only one
                if leadingActions.count == 1 {
                    triggerHaptic()
                    leadingActions[0].action()
                    withAnimation(AnimationTokens.dismiss) { offset = 0 }
                } else {
                    withAnimation(AnimationTokens.transition) { offset = maxLeadingReveal }
                }
            } else {
                withAnimation(AnimationTokens.transition) { offset = 0 }
            }
        } else {
            // Swiped left — snap to trailing reveal or close
            let absOffset = -offset
            if absOffset > maxTrailingReveal * threshold {
                if trailingActions.count == 1 {
                    triggerHaptic()
                    trailingActions[0].action()
                    withAnimation(AnimationTokens.dismiss) { offset = 0 }
                } else {
                    withAnimation(AnimationTokens.transition) { offset = -maxTrailingReveal }
                }
            } else {
                withAnimation(AnimationTokens.transition) { offset = 0 }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Swipeable Row") {
    struct SwipeableDemo: View {
        @State private var items = ["Meeting notes", "Design review", "Sprint planning", "Bug triage", "Weekly sync"]
        @State private var muted = Set<String>()

        var body: some View {
            NavigationStack {
                List {
                    ForEach(items, id: \.self) { item in
                        DKSwipeableRow(
                            leadingActions: [
                                DKSwipeAction(icon: "checkmark.circle", label: "Done", tint: .green) {
                                    withAnimation { items.removeAll { $0 == item } }
                                }
                            ],
                            trailingActions: [
                                DKSwipeAction(icon: "trash", label: "Delete", tint: .red, style: .destructive) {
                                    withAnimation { items.removeAll { $0 == item } }
                                },
                                DKSwipeAction(
                                    icon: muted.contains(item) ? "bell" : "bell.slash",
                                    label: muted.contains(item) ? "Unmute" : "Mute",
                                    tint: .gray
                                ) {
                                    if muted.contains(item) { muted.remove(item) } else { muted.insert(item) }
                                }
                            ]
                        ) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                Text(item)
                                Spacer()
                                if muted.contains(item) {
                                    Image(systemName: "bell.slash")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.adaptiveBackground)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Swipeable Rows")
            }
        }
    }
    return SwipeableDemo()
}
#endif

// MARK: - Platform Colors

private extension Color {
    static var adaptiveBackground: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
