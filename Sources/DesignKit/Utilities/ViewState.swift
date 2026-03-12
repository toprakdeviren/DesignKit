import SwiftUI

// MARK: - View State Enum

/// Represents the lifecycle of any asynchronously loaded content.
///
/// Use `DKViewState` as the single source of truth for a screen's data status,
/// then wrap your list/grid in `DKStateView` to get automatic loading skeletons,
/// empty states, and error states.
///
/// ```swift
/// @State var state: DKViewState<[Conversation]> = .idle
///
/// var body: some View {
///     DKStateView(state: state) { conversations in
///         ForEach(conversations) { ConversationRow($0) }
///     }
///     .task { state = .loading; state = await load() }
/// }
/// ```
public enum DKViewState<T> {
    /// Nothing has started yet (initial state).
    case idle
    /// A fetch is in progress.
    case loading
    /// Content arrived successfully.
    case loaded(T)
    /// Content arrived but the collection is empty.
    case empty(message: String = DKLocalizer.string(for: .stateEmpty),
               systemImage: String = "tray",
               action: EmptyAction? = nil)
    /// Fetch failed.
    case error(DKViewStateError)
}

// MARK: - Supporting Types

/// A user-facing error inside `DKViewState`.
public struct DKViewStateError: Error {
    public let message: String
    public let retry: (() -> Void)?

    public init(message: String, retry: (() -> Void)? = nil) {
        self.message = message
        self.retry = retry
    }

    public init(_ error: Error, retry: (() -> Void)? = nil) {
        self.message = error.localizedDescription
        self.retry = retry
    }
}

/// An optional action button rendered in the empty state.
public struct EmptyAction {
    public let title: String
    public let handler: () -> Void

    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - DKStateView

/// A generic container that renders different UI depending on `DKViewState`.
///
/// | State | Rendered UI |
/// |-------|-------------|
/// | `.idle` | Empty (nothing shown) |
/// | `.loading` | Skeleton shimmer |
/// | `.loaded(data)` | `content(data)` |
/// | `.empty(…)` | Illustration + message + optional CTA |
/// | `.error(…)` | Error message + Retry button |
///
/// ```swift
/// DKStateView(state: messagesState, skeletonLayout: .list(rows: 6)) { messages in
///     ForEach(messages) { MessageRow($0) }
/// }
/// ```
public struct DKStateView<T, Content: View>: View {

    // MARK: Properties

    private let state: DKViewState<T>
    private let skeletonLayout: DKSkeletonLayout
    private let content: (T) -> Content

    @Environment(\.designKitTheme) private var theme

    // MARK: Init

    public init(
        state: DKViewState<T>,
        skeletonLayout: DKSkeletonLayout = .list(rows: 5),
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.state = state
        self.skeletonLayout = skeletonLayout
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        Group {
            switch state {
            case .idle:
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loading:
                skeletonView

            case .loaded(let data):
                content(data)
                    .transition(.opacity)

            case .empty(let message, let systemImage, let action):
                emptyView(message: message, systemImage: systemImage, action: action)
                    .transition(.opacity)

            case .error(let error):
                errorView(error: error)
                    .transition(.opacity)
            }
        }
        .animation(AnimationTokens.appear, value: stateKey)
    }

    // MARK: - Skeleton

    @ViewBuilder
    private var skeletonView: some View {
        switch skeletonLayout {
        case .list(let rows):
            VStack(spacing: 12) {
                ForEach(0..<rows, id: \.self) { _ in
                    DKSkeletonRow()
                }
            }
            .padding(.horizontal)

        case .grid(let columns, let rows):
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns), spacing: 12) {
                ForEach(0..<(columns * rows), id: \.self) { _ in
                    DKSkeletonCard()
                }
            }
            .padding(.horizontal)

        case .card:
            VStack(spacing: 16) {
                DKSkeletonCard()
                DKSkeletonCard()
                DKSkeletonCard()
            }
            .padding(.horizontal)

        case .custom(let view):
            view
        }
    }

    // MARK: - Empty State

    private func emptyView(message: String, systemImage: String, action: EmptyAction?) -> some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .light))
                .foregroundColor(theme.colorTokens.neutral400)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.colorTokens.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let action {
                Button(action.title, action: action.handler)
                    .buttonStyle(.bordered)
                    .tint(theme.colorTokens.primary500)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: - Error State

    private func errorView(error: DKViewStateError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(theme.colorTokens.warning500)

            VStack(spacing: 8) {
                Text(DKLocalizer.string(for: .stateError))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.colorTokens.textPrimary)

                Text(error.message)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let retry = error.retry {
                DKButton(DKLocalizer.string(for: .buttonRetry), variant: .primary) {
                    retry()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: - State Key for Animation

    private var stateKey: String {
        switch state {
        case .idle:      return "idle"
        case .loading:   return "loading"
        case .loaded:    return "loaded"
        case .empty:     return "empty"
        case .error:     return "error"
        }
    }
}

// MARK: - Skeleton Layout

/// Describes what skeleton UI to show while loading.
public enum DKSkeletonLayout {
    /// A vertical list of skeleton rows (think: table view).
    case list(rows: Int)
    /// A grid of skeleton cards.
    case grid(columns: Int, rows: Int)
    /// Three large skeleton cards (think: feed).
    case card
    /// Fully custom skeleton view.
    case custom(AnyView)
}

// MARK: - Skeleton Primitives

private struct DKSkeletonRow: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(shimmerGradient)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)

                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 10)
                    .frame(maxWidth: 180)
            }
        }
        .onAppear { withAnimation(AnimationTokens.pulse) { shimmer.toggle() } }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.shimmerBase,
                Color.shimmerHighlight,
                Color.shimmerBase
            ],
            startPoint: shimmer ? .topLeading : .bottomTrailing,
            endPoint: shimmer ? .bottomTrailing : .topLeading
        )
    }
}

private struct DKSkeletonCard: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(shimmerGradient)
            .frame(height: 120)
            .onAppear { withAnimation(AnimationTokens.pulse) { shimmer.toggle() } }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.shimmerBase, Color.shimmerHighlight, Color.shimmerBase],
            startPoint: shimmer ? .topLeading : .bottomTrailing,
            endPoint: shimmer ? .bottomTrailing : .topLeading
        )
    }
}

// MARK: - Cross-Platform Shimmer Colors

private extension Color {
    static var shimmerBase: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.systemGray5)
        #else
        return Color(NSColor.windowBackgroundColor).opacity(0.7)
        #endif
    }

    static var shimmerHighlight: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.systemGray4)
        #else
        return Color(NSColor.windowBackgroundColor).opacity(0.4)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ViewState") {
    struct StateDemo: View {
        @State private var selected = 0
        private let tabs = ["Idle", "Loading", "Loaded", "Empty", "Error"]

        var currentState: DKViewState<[String]> {
            switch selected {
            case 0: return .idle
            case 1: return .loading
            case 2: return .loaded(["Alice", "Bob", "Carol", "Dave", "Eve"])
            case 3: return .empty(message: "No conversations yet", systemImage: "bubble.left.and.bubble.right",
                                  action: EmptyAction(title: "New Conversation") {})
            case 4: return .error(DKViewStateError(message: "Could not reach the server. Check your internet connection.", retry: {}))
            default: return .idle
            }
        }

        var body: some View {
            VStack {
                Picker("State", selection: $selected) {
                    ForEach(tabs.indices, id: \.self) { i in
                        Text(tabs[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                DKStateView(state: currentState, skeletonLayout: .list(rows: 5)) { names in
                    List(names, id: \.self) { name in
                        Label(name, systemImage: "person.circle")
                    }
                }
            }
        }
    }
    return StateDemo()
}
#endif
