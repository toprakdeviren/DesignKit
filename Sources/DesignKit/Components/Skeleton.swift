import SwiftUI

/// Skeleton shape variants
public enum SkeletonShape {
    case rectangle
    case circle
    case roundedRectangle(radius: CGFloat)
}

/// A skeleton loader component for loading states
public struct DKSkeleton: View {
    
    // MARK: - Properties
    
    private let width: CGFloat?
    private let height: CGFloat
    private let shape: SkeletonShape
    private let animated: Bool
    
    @Environment(\.designKitTheme) private var theme
    @State private var isAnimating = false
    
    // MARK: - Initialization
    
    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        shape: SkeletonShape = .rectangle,
        animated: Bool = true
    ) {
        self.width = width
        self.height = height
        self.shape = shape
        self.animated = animated
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base
                Rectangle()
                    .fill(theme.colorTokens.neutral200)
                
                // Shimmer
                if animated {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    theme.colorTokens.neutral300.opacity(0.5),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            }
            .mask(maskShape)
        }
        .frame(width: width, height: height)
        .onAppear {
            if animated {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DKLocalizer.string(for: .a11yLoading))
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private var maskShape: some View {
        switch shape {
        case .rectangle:
            Rectangle()
        case .circle:
            Circle()
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius)
        }
    }
}

// MARK: - Skeleton Group

/// Pre-configured skeleton layouts
public struct DKSkeletonGroup: View {
    
    public enum Layout {
        case text(lines: Int)
        case card
        case avatar
        case listItem
    }
    
    private let layout: Layout
    
    public init(layout: Layout) {
        self.layout = layout
    }
    
    public var body: some View {
        Group {
            switch layout {
            case .text(let lines):
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<lines, id: \.self) { index in
                        DKSkeleton(
                            width: index == lines - 1 ? 200 : nil,
                            height: 16,
                            shape: .roundedRectangle(radius: 4)
                        )
                    }
                }
                
            case .card:
                VStack(alignment: .leading, spacing: 12) {
                    DKSkeleton(height: 200, shape: .roundedRectangle(radius: 12))
                    DKSkeleton(width: 150, height: 20, shape: .roundedRectangle(radius: 4))
                    DKSkeleton(height: 16, shape: .roundedRectangle(radius: 4))
                    DKSkeleton(width: 200, height: 16, shape: .roundedRectangle(radius: 4))
                }
                
            case .avatar:
                HStack(spacing: 12) {
                    DKSkeleton(width: 48, height: 48, shape: .circle)
                    VStack(alignment: .leading, spacing: 8) {
                        DKSkeleton(width: 120, height: 16, shape: .roundedRectangle(radius: 4))
                        DKSkeleton(width: 80, height: 12, shape: .roundedRectangle(radius: 4))
                    }
                }
                
            case .listItem:
                HStack(spacing: 12) {
                    DKSkeleton(width: 40, height: 40, shape: .roundedRectangle(radius: 8))
                    VStack(alignment: .leading, spacing: 6) {
                        DKSkeleton(width: 150, height: 14, shape: .roundedRectangle(radius: 4))
                        DKSkeleton(width: 100, height: 12, shape: .roundedRectangle(radius: 4))
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Skeleton Loaders") {
    ScrollView {
        VStack(alignment: .leading, spacing: 30) {
            Text("Shapes")
                .textStyle(.headline)
            
            VStack(spacing: 12) {
                DKSkeleton(height: 20, shape: .rectangle)
                DKSkeleton(width: 60, height: 60, shape: .circle)
                DKSkeleton(height: 80, shape: .roundedRectangle(radius: 12))
            }
            
            Text("Pre-configured Layouts")
                .textStyle(.headline)
            
            DKSkeletonGroup(layout: .text(lines: 3))
            
            DKSkeletonGroup(layout: .avatar)
            
            DKSkeletonGroup(layout: .card)
            
            DKSkeletonGroup(layout: .listItem)
        }
        .padding()
    }
}
#endif

