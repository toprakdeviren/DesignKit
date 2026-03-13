import SwiftUI

// MARK: - Loading Priority

/// Hints to the image loader how urgently this image is needed.
public enum DKImagePriority {
    /// Visible above-the-fold content (avatars, hero images).
    case high
    /// Standard list/grid items.
    case normal
    /// Off-screen prefetch or background images.
    case low
}

// MARK: - Image Transition

/// The visual transition to play when the image finishes loading.
public enum DKImageTransition {
    case fade(duration: Double = 0.25)
    case scale(from: CGFloat = 0.92, duration: Double = 0.3)
    case none
}

// MARK: - Image Placeholder

/// What to show while the image is loading.
public enum DKImagePlaceholder {
    /// Animated shimmer skeleton (default).
    case skeleton
    /// A solid color fill.
    case color(Color)
    /// Any SF Symbol icon.
    case icon(String, color: Color = .secondary)
    /// A fully custom view.
    case custom(AnyView)
}

// MARK: - Image Cache

/// Simple in-memory URL → UIImage/NSImage cache shared across all `DKLazyImage` instances.
@MainActor
final class DKImageCache {
    static let shared = DKImageCache()
    private init() {}

    private var store: [URL: PlatformImage] = [:]
    private let maxItems = 200

    func image(for url: URL) -> PlatformImage? { store[url] }

    func store(_ image: PlatformImage, for url: URL) {
        if store.count >= maxItems {
            store.removeValue(forKey: store.keys.first!)
        }
        store[url] = image
    }
}

#if canImport(UIKit)
typealias PlatformImage = UIImage
#else
typealias PlatformImage = NSImage
#endif

// MARK: - DKLazyImage

/// A production-grade async image loader with caching, retries, priority,
/// placeholder states, and configurable transition animations.
///
/// Drop-in replacement for `AsyncImage` with better control:
///
/// ```swift
/// // Avatar
/// DKLazyImage(url: user.avatarURL, priority: .high)
///
/// // Feed image with custom placeholder
/// DKLazyImage(
///     url: post.imageURL,
///     placeholder: .skeleton,
///     transition: .fade(),
///     failureView: Image(systemName: "photo").foregroundStyle(.secondary)
/// )
/// .frame(height: 200)
/// .cornerRadius(12)
/// ```
public struct DKLazyImage<Failure: View>: View {

    // MARK: Properties

    private let url: URL?
    private let placeholder: DKImagePlaceholder
    private let transition: DKImageTransition
    private let priority: DKImagePriority
    private let maxRetries: Int
    private let cachePolicy: URLRequest.CachePolicy
    private let contentMode: ContentMode
    private let failureView: Failure

    @State private var loadState: LoadState = .idle
    @State private var retryCount = 0
    @State private var isVisible = false

    @Environment(\.designKitTheme) private var theme

    private enum LoadState {
        case idle, loading, loaded(PlatformImage), failed(Error)
    }

    // MARK: Init

    public init(
        url: URL?,
        placeholder: DKImagePlaceholder = .skeleton,
        transition: DKImageTransition = .fade(),
        priority: DKImagePriority = .normal,
        maxRetries: Int = 2,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        contentMode: ContentMode = .fill,
        @ViewBuilder failureView: () -> Failure
    ) {
        self.url = url
        self.placeholder = placeholder
        self.transition = transition
        self.priority = priority
        self.maxRetries = maxRetries
        self.cachePolicy = cachePolicy
        self.contentMode = contentMode
        self.failureView = failureView()
    }

    // MARK: Body

    public var body: some View {
        ZStack {
            switch loadState {
            case .idle, .loading:
                placeholderView

            case .loaded(let image):
                imageView(image)
                    .transition(resolvedTransition)

            case .failed:
                failureView
                    .transition(.opacity)
            }
        }
        .animation(transitionAnimation, value: isLoaded)
        .onAppear { Task { await load() } }
    }

    // MARK: - Image View

    @ViewBuilder
    private func imageView(_ image: PlatformImage) -> some View {
        #if canImport(UIKit)
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
        #else
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
        #endif
    }

    // MARK: - Placeholder

    @ViewBuilder
    private var placeholderView: some View {
        switch placeholder {
        case .skeleton:
            DKLazyShimmerView()

        case .color(let c):
            c

        case .icon(let name, let color):
            ZStack {
                Color.secondary.opacity(0.1)
                Image(systemName: name)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }

        case .custom(let view):
            view
        }
    }

    // MARK: - Loading

    private func load() async {
        guard let url else { loadState = .failed(URLError(.badURL)); return }

        // Cache hit — instant
        if let cached = DKImageCache.shared.image(for: url) {
            withAnimation(transitionAnimation) { loadState = .loaded(cached) }
            isVisible = true
            return
        }

        loadState = .loading

        // Priority → QoS
        let qos: TaskPriority = switch priority {
        case .high:   .userInitiated
        case .normal: .utility
        case .low:    .background
        }

        await Task(priority: qos) {
            await fetchWithRetry(url: url)
        }.value
    }

    private func fetchWithRetry(url: URL) async {
        for attempt in 0...maxRetries {
            do {
                var request = URLRequest(url: url, cachePolicy: cachePolicy)
                request.timeoutInterval = 15
                let (data, _) = try await URLSession.shared.data(for: request)

                #if canImport(UIKit)
                guard let img = UIImage(data: data) else { throw URLError(.cannotDecodeContentData) }
                #else
                guard let img = NSImage(data: data) else { throw URLError(.cannotDecodeContentData) }
                #endif

                DKImageCache.shared.store(img, for: url)

                await MainActor.run {
                    withAnimation(transitionAnimation) {
                        loadState = .loaded(img)
                        isVisible = true
                    }
                }
                return

            } catch {
                if attempt == maxRetries {
                    await MainActor.run {
                        withAnimation(AnimationTokens.micro) { loadState = .failed(error) }
                    }
                } else {
                    // Exponential backoff: 0.5s, 1s, 2s…
                    let delay = UInt64(pow(2.0, Double(attempt)) * 500_000_000)
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }
    }

    // MARK: - Helpers

    private var isLoaded: Bool {
        if case .loaded = loadState { return true }
        return false
    }

    private var resolvedTransition: AnyTransition {
        switch transition {
        case .fade:             return .opacity
        case .scale(let s, _): return .scale(scale: s).combined(with: .opacity)
        case .none:             return .identity
        }
    }

    private var transitionAnimation: Animation? {
        switch transition {
        case .fade(let d):      return .easeOut(duration: d)
        case .scale(_, let d): return .spring(response: d, dampingFraction: 0.8)
        case .none:             return nil
        }
    }
}

// MARK: - Convenience init (no failure view)

extension DKLazyImage where Failure == AnyView {
    public init(
        url: URL?,
        placeholder: DKImagePlaceholder = .skeleton,
        transition: DKImageTransition = .fade(),
        priority: DKImagePriority = .normal,
        maxRetries: Int = 2,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        contentMode: ContentMode = .fill
    ) {
        self.init(
            url: url,
            placeholder: placeholder,
            transition: transition,
            priority: priority,
            maxRetries: maxRetries,
            cachePolicy: cachePolicy,
            contentMode: contentMode
        ) {
            AnyView(
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            )
        }
    }
}

// MARK: - Shimmer View

private struct DKLazyShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let gradient = LinearGradient(
                stops: [
                    .init(color: Color.secondary.opacity(0.12), location: max(0, phase - 0.3)),
                    .init(color: Color.secondary.opacity(0.28), location: phase),
                    .init(color: Color.secondary.opacity(0.12), location: min(1, phase + 0.3))
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            Rectangle()
                .fill(gradient)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                phase = 1.3
            }
        }
        .clipped()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("LazyImage") {
    ScrollView {
        VStack(spacing: 24) {
            Text("DKLazyImage").font(.title2.bold())

            // Valid image
            DKLazyImage(url: URL(string: "https://picsum.photos/seed/dk1/400/300"))
                .frame(height: 200)
                .cornerRadius(16)
                .shadow(radius: 8)

            // Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(1...9, id: \.self) { i in
                    DKLazyImage(url: URL(string: "https://picsum.photos/seed/dk\(i)/200/200"),
                                transition: .scale())
                        .frame(height: 110)
                        .clipped()
                }
            }

            // Invalid URL → failure view
            DKLazyImage(url: URL(string: "https://invalid.url/not-found.jpg")) {
                ZStack {
                    Color.red.opacity(0.1)
                    Label("Failed to load", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
            .frame(height: 120)
            .cornerRadius(12)

            // Skeleton placeholder
            DKLazyImage(url: nil, placeholder: .skeleton)
                .frame(height: 80)
                .cornerRadius(8)
        }
        .padding()
    }
}
#endif
