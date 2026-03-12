import SwiftUI

/// A scroll view with infinite scroll (pagination) support
public struct DKInfiniteScroll<Content: View, Data: Identifiable>: View {
    
    // MARK: - Properties
    
    private let data: [Data]
    private let isLoading: Bool
    private let hasMore: Bool
    private let threshold: CGFloat
    private let onLoadMore: () -> Void
    private let content: (Data) -> Content
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        data: [Data],
        isLoading: Bool = false,
        hasMore: Bool = true,
        threshold: CGFloat = 100,
        onLoadMore: @escaping () -> Void,
        @ViewBuilder content: @escaping (Data) -> Content
    ) {
        self.data = data
        self.isLoading = isLoading
        self.hasMore = hasMore
        self.threshold = threshold
        self.onLoadMore = onLoadMore
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { item in
                    content(item)
                }
                
                // Loading indicator at bottom
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                } else if hasMore {
                    // Invisible trigger view
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            onLoadMore()
                        }
                } else {
                    // End of content indicator
                    Text("Tümü yüklendi")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textTertiary)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DKInfiniteScroll_Previews: PreviewProvider {
    static var previews: some View {
        InfiniteScrollDemo()
    }
}

struct InfiniteScrollDemo: View {
    @State private var items: [MockItem] = (1...20).map { MockItem(id: UUID(), title: "Item \($0)") }
    @State private var isLoading = false
    @State private var hasMore = true
    
    var body: some View {
        DKInfiniteScroll(
            data: items,
            isLoading: isLoading,
            hasMore: hasMore,
            onLoadMore: loadMore
        ) { item in
            HStack {
                Text(item.title)
                    .textStyle(.body)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
    
    private func loadMore() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let currentCount = items.count
            let newItems = (currentCount + 1...currentCount + 20).map { 
                MockItem(id: UUID(), title: "Item \($0)") 
            }
            items.append(contentsOf: newItems)
            isLoading = false
            
            // Simulate end of data
            if items.count >= 100 {
                hasMore = false
            }
        }
    }
}

struct MockItem: Identifiable {
    let id: UUID
    let title: String
}
#endif

