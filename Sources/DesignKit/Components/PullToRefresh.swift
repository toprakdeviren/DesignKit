import SwiftUI

/// A scroll view with pull-to-refresh functionality
public struct DKPullToRefresh<Content: View>: View {
    
    // MARK: - Properties
    
    private let content: () -> Content
    private let onRefresh: () async -> Void
    
    @Environment(\.designKitTheme) private var theme
    @State private var isRefreshing = false
    
    // MARK: - Initialization
    
    public init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            content()
        }
        .refreshable {
            await performRefresh()
        }
    }
    
    // MARK: - Private Helpers
    
    private func performRefresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
        
        await onRefresh()
        isRefreshing = false
    }
}

// MARK: - Custom Pull to Refresh (for more control)

/// A custom pull-to-refresh implementation with visual indicator
public struct DKCustomPullToRefresh<Content: View>: View {
    
    // MARK: - Properties
    
    private let content: () -> Content
    private let onRefresh: () async -> Void
    private let threshold: CGFloat
    
    @Environment(\.designKitTheme) private var theme
    @State private var isRefreshing = false
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    public init(
        threshold: CGFloat = 80,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.threshold = threshold
        self.onRefresh = onRefresh
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Refresh Indicator
                refreshIndicator
                
                // Content
                content()
            }
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
            
            if value > threshold && !isRefreshing {
                Task {
                    await performRefresh()
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private var refreshIndicator: some View {
        HStack {
            Spacer()
            
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colorTokens.primary500))
            } else if scrollOffset > 0 {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colorTokens.primary500)
                    .rotationEffect(.degrees(scrollOffset > threshold ? 180 : 0))
                    .animation(.spring(), value: scrollOffset)
            }
            
            Spacer()
        }
        .frame(height: max(0, min(scrollOffset, threshold)))
        .opacity(min(scrollOffset / threshold, 1.0))
    }
    
    private func performRefresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
        
        await onRefresh()
        
        // Add small delay for better UX
        try? await Task.sleep(nanoseconds: 500_000_000)
        isRefreshing = false
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#if DEBUG
struct DKPullToRefresh_Previews: PreviewProvider {
    static var previews: some View {
        PullToRefreshDemo()
    }
}

struct PullToRefreshDemo: View {
    @State private var items: [String] = (1...20).map { "Item \($0)" }
    
    var body: some View {
        DKPullToRefresh(onRefresh: refresh) {
            LazyVStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .textStyle(.body)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func refresh() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        items = (1...20).map { "Item \($0) (Yenilendi)" }
    }
}
#endif

