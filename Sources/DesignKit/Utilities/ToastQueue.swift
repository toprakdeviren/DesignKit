import SwiftUI

// MARK: - Toast Action

/// An optional action button shown inside a toast notification.
public struct DKToastAction {
    public let title: String
    public let handler: () -> Void

    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - Toast Item

/// A single item waiting in (or currently shown from) the queue.
public struct DKToastItem: Identifiable {
    public let id: UUID
    public let message: String
    public let variant: ToastVariant
    public let icon: String?
    public let duration: TimeInterval
    public let action: DKToastAction?

    public init(
        id: UUID = UUID(),
        message: String,
        variant: ToastVariant = .info,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        action: DKToastAction? = nil
    ) {
        self.id = id
        self.message = message
        self.variant = variant
        self.icon = icon
        self.duration = duration
        self.action = action
    }
}

// MARK: - Toast Queue

/// A singleton queue that serialises toast notifications so they never overlap.
///
/// Enqueue toasts from anywhere in the app:
/// ```swift
/// DKToastQueue.shared.show("File saved", variant: .success)
///
/// DKToastQueue.shared.show(
///     "Message deleted",
///     variant: .warning,
///     action: DKToastAction(title: "Undo") { restoreMessage() }
/// )
/// ```
///
/// Attach the overlay once at your root view with `.dkToastOverlay()`:
/// ```swift
/// ContentView()
///     .dkToastOverlay()
/// ```
@MainActor
public final class DKToastQueue: ObservableObject {

    // MARK: Singleton

    public static let shared = DKToastQueue()
    private init() {}

    // MARK: State

    /// The item currently on screen. `nil` means nothing is displayed.
    @Published public private(set) var current: DKToastItem?

    /// Items waiting to be shown after `current` is dismissed.
    private var pending: [DKToastItem] = []

    /// Whether the top-of-screen overlay is visible (drives animation).
    @Published public private(set) var isShowing = false

    // MARK: Public API

    /// Enqueue a new toast. It is shown immediately if nothing is on screen.
    public func show(
        _ message: String,
        variant: ToastVariant = .info,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        action: DKToastAction? = nil
    ) {
        let item = DKToastItem(
            message: message,
            variant: variant,
            icon: icon,
            duration: duration,
            action: action
        )
        enqueue(item)
    }

    /// Enqueue a pre-built `DKToastItem`.
    public func show(_ item: DKToastItem) {
        enqueue(item)
    }

    /// Dismiss the current toast immediately.
    public func dismissCurrent() {
        guard isShowing else { return }
        hide()
    }

    /// Clear all queued items, including the one currently on screen.
    public func clearAll() {
        pending.removeAll()
        hide()
    }

    // MARK: Private Queue Logic

    private func enqueue(_ item: DKToastItem) {
        if current == nil {
            present(item)
        } else {
            pending.append(item)
        }
    }

    private func present(_ item: DKToastItem) {
        current = item
        withAnimation(AnimationTokens.appear) { isShowing = true }

        // Schedule auto-dismiss
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(item.duration * 1_000_000_000))
            // Only auto-dismiss if this is still the current item
            // (the user may have manually dismissed it already)
            if current?.id == item.id {
                hide()
            }
        }
    }

    private func hide() {
        withAnimation(AnimationTokens.dismiss) { isShowing = false }
        // Wait for dismiss animation to complete before showing the next item.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(AnimationTokens.Duration.fast.rawValue * 1_000_000_000))
            current = nil
            if let next = pending.first {
                pending.removeFirst()
                // Small gap between toasts for clarity
                try? await Task.sleep(nanoseconds: 80_000_000) // 80 ms
                present(next)
            }
        }
    }
}

// MARK: - Queue-Driven Toast View

/// The actual on-screen view driven by `DKToastQueue`.
/// Attach it once via `.dkToastOverlay()`.
private struct DKToastQueueOverlay: View {
    @ObservedObject var queue: DKToastQueue
    let position: ToastPosition

    @Environment(\.designKitTheme) private var theme

    var body: some View {
        if let item = queue.current {
            toastView(for: item)
                .id(item.id)           // force re-render on each new item
                .transition(transition(for: position))
                .zIndex(9999)
        }
    }

    private func toastView(for item: DKToastItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon ?? defaultIcon(for: item.variant))
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))

            Text(item.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer(minLength: 0)

            if let action = item.action {
                Button(action.title) {
                    action.handler()
                    queue.dismissCurrent()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            }

            Button {
                queue.dismissCurrent()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor(for: item.variant))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(position == .top ? .top : .bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(variantLabel(for: item.variant)): \(item.message)")
        .accessibilityAddTraits(.isStaticText)
    }

    private func backgroundColor(for variant: ToastVariant) -> Color {
        let c = theme.colorTokens
        switch variant {
        case .info:    return c.primary500
        case .success: return c.success500
        case .warning: return c.warning500
        case .error:   return c.danger500
        }
    }

    private func defaultIcon(for variant: ToastVariant) -> String {
        switch variant {
        case .info:    return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error:   return "xmark.circle.fill"
        }
    }

    private func variantLabel(for variant: ToastVariant) -> String {
        switch variant {
        case .info:    return DKLocalizer.string(for: .toastInfo)
        case .success: return DKLocalizer.string(for: .toastSuccess)
        case .warning: return DKLocalizer.string(for: .toastWarning)
        case .error:   return DKLocalizer.string(for: .toastError)
        }
    }

    private func transition(for position: ToastPosition) -> AnyTransition {
        let edge: Edge = position == .top ? .top : .bottom
        return .move(edge: edge).combined(with: .opacity)
    }
}

// MARK: - View Modifier

private struct DKToastOverlayModifier: ViewModifier {
    @ObservedObject var queue: DKToastQueue
    let position: ToastPosition

    func body(content: Content) -> some View {
        ZStack(alignment: position == .top ? .top : .bottom) {
            content
            DKToastQueueOverlay(queue: queue, position: position)
        }
        .animation(AnimationTokens.appear, value: queue.isShowing)
    }
}

public extension View {
    /// Attaches the DesignKit toast overlay to this view.
    ///
    /// Call once on your root view so every `DKToastQueue.shared.show(…)` call
    /// in the app renders correctly.
    ///
    /// ```swift
    /// WindowGroup { ContentView().dkToastOverlay() }
    /// ```
    @MainActor
    func dkToastOverlay(
        queue: DKToastQueue? = nil,
        position: ToastPosition = .top
    ) -> some View {
        modifier(DKToastOverlayModifier(queue: queue ?? .shared, position: position))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Toast Queue") {
    struct ToastQueuePreview: View {
        var body: some View {
            VStack(spacing: 16) {
                Text("Toast Queue Manager")
                    .font(.title2.bold())
                    .padding(.bottom, 8)

                Group {
                    Button("Show Info") {
                        DKToastQueue.shared.show("Document opened", variant: .info)
                    }

                    Button("Show Success") {
                        DKToastQueue.shared.show("File saved successfully", variant: .success)
                    }

                    Button("Show with Undo Action") {
                        DKToastQueue.shared.show(
                            "Message deleted",
                            variant: .warning,
                            action: DKToastAction(title: "Undo") {
                                print("Undo tapped")
                            }
                        )
                    }

                    Button("Show Error") {
                        DKToastQueue.shared.show("Connection failed", variant: .error)
                    }

                    Button("Spam 3 toasts") {
                        DKToastQueue.shared.show("First toast", variant: .info)
                        DKToastQueue.shared.show("Second toast", variant: .success)
                        DKToastQueue.shared.show("Third toast", variant: .warning)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .dkToastOverlay(position: .top)
        }
    }

    return ToastQueuePreview()
}
#endif
