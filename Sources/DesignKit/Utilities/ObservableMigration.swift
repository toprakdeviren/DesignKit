import SwiftUI

// MARK: - @Observable Migration
//
// iOS 17 / macOS 14 / Swift 5.9+ introduced the `@Observable` macro as a
// replacement for `ObservableObject` + `@Published`. Key benefits:
//
// - No need for `@Published` on each property — all stored properties are
//   automatically tracked.
// - Views only re-render when a property they actually *read* changes (not
//   the entire object). This can eliminate many unnecessary re-renders in
//   complex screens.
// - Works with `@Bindable` for two-way bindings in views.
//
// Migration Strategy
// ------------------
// Because DesignKit targets iOS 16+, we cannot drop `ObservableObject`
// outright. Instead we use conditional compilation:
//
//   #if swift(>=5.9) — always true on Swift 5.9+
//   @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
//   @Observable final class DKToastQueueV2 { … }
//
// Host apps on iOS 17+ automatically use the faster path; apps that are
// still on iOS 16 fall back to the existing `ObservableObject` version.
//
// This file contains:
//  1. The @Observable variant of DKToastQueue (DKToastQueueObservable)
//  2. A factory that returns the right one at call site
//  3. An @Observable DesignKit theme store

// MARK: - @Observable Toast Queue (iOS 17+)

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
public final class DKToastQueueObservable {

    // MARK: Singleton

    public static let shared = DKToastQueueObservable()
    private init() {}

    // MARK: Observed State

    public private(set) var current: DKToastItem?
    public private(set) var isShowing = false

    // MARK: Internal

    private var pending: [DKToastItem] = []

    // MARK: API

    public func show(
        _ message: String,
        variant: ToastVariant = .info,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        action: DKToastAction? = nil
    ) {
        let item = DKToastItem(message: message, variant: variant, icon: icon, duration: duration, action: action)
        enqueue(item)
    }

    public func dismissCurrent() {
        guard isShowing else { return }
        hide()
    }

    public func clearAll() {
        pending.removeAll()
        hide()
    }

    // MARK: Private

    private func enqueue(_ item: DKToastItem) {
        if current == nil { present(item) } else { pending.append(item) }
    }

    private func present(_ item: DKToastItem) {
        current = item
        withAnimation(AnimationTokens.appear) { isShowing = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(item.duration * 1_000_000_000))
            if current?.id == item.id { hide() }
        }
    }

    private func hide() {
        withAnimation(AnimationTokens.dismiss) { isShowing = false }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(AnimationTokens.Duration.fast.rawValue * 1_000_000_000))
            current = nil
            if let next = pending.first {
                pending.removeFirst()
                try? await Task.sleep(nanoseconds: 80_000_000)
                present(next)
            }
        }
    }
}

// MARK: - @Observable Theme Store (iOS 17+)

/// An @Observable theme store so views re-render only when the specific token
/// they use actually changes — not on every `objectWillChange` of the theme.
///
/// Usage (iOS 17+):
/// ```swift
/// @State private var themeStore = DKThemeStore(theme: MyCustomTheme())
///
/// ContentView()
///     .environment(themeStore)
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
public final class DKThemeStore {
    public var theme: Theme

    public init(theme: Theme = .default) {
        self.theme = theme
    }
}

// MARK: - @Observable ViewState Store (iOS 17+)

/// An @Observable generic state machine for any single async resource.
///
/// Usage (iOS 17+):
/// ```swift
/// @State private var store = DKStateStore<[Message]>()
///
/// var body: some View {
///     DKStateView(state: store.state) { messages in
///         ForEach(messages) { MessageRow($0) }
///     }
///     .task { await store.load { try await api.fetchMessages() } }
/// }
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
public final class DKStateStore<T> {
    public private(set) var state: DKViewState<T> = .idle

    public init() {}

    /// Runs `operation`, updating `state` through loading → loaded/error.
    @MainActor
    public func load(_ operation: @escaping () async throws -> T) async {
        state = .loading
        do {
            let value = try await operation()
            withAnimation(AnimationTokens.appear) { state = .loaded(value) }
        } catch {
            let captured = operation
            withAnimation(AnimationTokens.micro) {
                state = .error(DKViewStateError(error) { [weak self] in
                    Task { await self?.load(captured) }
                })
            }
        }
    }

    @MainActor
    public func reset() { state = .idle }
}

// MARK: - Migration Guide (Doc Comment)
//
// ## ObservableObject → @Observable Migration Checklist
//
// ### Step 1 — Guard with availability
// ```swift
// @available(iOS 17, *)
// @Observable final class MyStore { var items: [Item] = [] }
// ```
//
// ### Step 2 — Remove @Published
// Before:  `@Published var items: [Item] = []`
// After:   `var items: [Item] = []`  (tracked automatically)
//
// ### Step 3 — Update views
// Before:  `@ObservedObject var store: MyStore`
// After:   `@State private var store = MyStore()`
//           or `@Bindable var store: MyStore` for bindings
//
// ### Step 4 — Remove @EnvironmentObject
// Before:  `.environmentObject(store)` + `@EnvironmentObject var store`
// After:   `.environment(store)` + `@Environment(MyStore.self) var store`
//
// ### Step 5 — Test re-render granularity
// With @Observable, a view that only reads `store.title` will NOT re-render
// when `store.items` changes. Verify your views are reading the minimum needed.
