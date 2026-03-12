import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Core Animation Shimmer (Optimized)

#if canImport(UIKit)

/// Hardware-accelerated shimmer using CAGradientLayer
final class CAShimmerLayer: CAGradientLayer {
    
    // MARK: - Properties
    
    private let shimmerAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupGradient()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        // Horizontal gradient
        startPoint = CGPoint(x: 0, y: 0.5)
        endPoint = CGPoint(x: 1, y: 0.5)
        
        // Shimmer colors (base → highlight → base)
        let baseColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        let highlightColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        
        colors = [baseColor, highlightColor, baseColor]
        locations = [0.0, 0.5, 1.0]
    }
    
    // MARK: - Animation Control
    
    func startShimmering() {
        add(shimmerAnimation, forKey: "shimmer")
    }
    
    func stopShimmering() {
        removeAnimation(forKey: "shimmer")
    }
    
    override func action(forKey event: String) -> CAAction? {
        // Disable implicit animations
        if event == "locations" {
            return nil
        }
        return super.action(forKey: event)
    }
}

/// UIView wrapper for CAShimmerLayer
public class ShimmerView: UIView {
    
    private let shimmerLayer = CAShimmerLayer()
    private let maskShape: SkeletonShape
    
    public init(shape: SkeletonShape) {
        self.maskShape = shape
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.addSublayer(shimmerLayer)
        shimmerLayer.startShimmering()
        
        // Apply mask for shape
        switch maskShape {
        case .rectangle:
            layer.cornerRadius = 0
        case .circle:
            // Will be set in layoutSubviews
            break
        case .roundedRectangle(let radius):
            layer.cornerRadius = radius
        }
        
        layer.masksToBounds = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
        
        // Update circle mask if needed
        if case .circle = maskShape {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }
    }
    
    deinit {
        shimmerLayer.stopShimmering()
    }
}

// MARK: - SwiftUI Bridge

/// Hardware-accelerated skeleton with Core Animation shimmer (iOS)
@available(iOS 16.0, *)
public struct DKSkeletonOptimized: UIViewRepresentable {
    
    private let width: CGFloat?
    private let height: CGFloat
    private let shape: SkeletonShape
    private let animated: Bool
    
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
    
    public func makeUIView(context: Context) -> ShimmerView {
        let view = ShimmerView(shape: shape)
        view.backgroundColor = .clear
        return view
    }
    
    public func updateUIView(_ uiView: ShimmerView, context: Context) {
        // View updates handled by Auto Layout
    }
}

#elseif canImport(AppKit)

// MARK: - macOS Implementation

/// Hardware-accelerated shimmer using CAGradientLayer (macOS)
final class CAShimmerLayer: CAGradientLayer {
    
    private let shimmerAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }()
    
    override init() {
        super.init()
        setupGradient()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        startPoint = CGPoint(x: 0, y: 0.5)
        endPoint = CGPoint(x: 1, y: 0.5)
        
        let baseColor = NSColor(white: 0.85, alpha: 1.0).cgColor
        let highlightColor = NSColor(white: 0.95, alpha: 1.0).cgColor
        
        colors = [baseColor, highlightColor, baseColor]
        locations = [0.0, 0.5, 1.0] as [NSNumber]
    }
    
    func startShimmering() {
        add(shimmerAnimation, forKey: "shimmer")
    }
    
    func stopShimmering() {
        removeAnimation(forKey: "shimmer")
    }
}

public class ShimmerView: NSView {
    
    private let shimmerLayer = CAShimmerLayer()
    private let maskShape: SkeletonShape
    
    public init(shape: SkeletonShape) {
        self.maskShape = shape
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        wantsLayer = true
        layer?.addSublayer(shimmerLayer)
        shimmerLayer.startShimmering()
        
        switch maskShape {
        case .rectangle:
            layer?.cornerRadius = 0
        case .circle:
            break
        case .roundedRectangle(let radius):
            layer?.cornerRadius = radius
        }
        
        layer?.masksToBounds = true
    }
    
    public override func layout() {
        super.layout()
        shimmerLayer.frame = bounds
        
        if case .circle = maskShape {
            layer?.cornerRadius = min(bounds.width, bounds.height) / 2
        }
    }
    
    deinit {
        shimmerLayer.stopShimmering()
    }
}

@available(macOS 13.0, *)
public struct DKSkeletonOptimized: NSViewRepresentable {
    
    private let width: CGFloat?
    private let height: CGFloat
    private let shape: SkeletonShape
    private let animated: Bool
    
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
    
    public func makeNSView(context: Context) -> ShimmerView {
        let view = ShimmerView(shape: shape)
        return view
    }
    
    public func updateNSView(_ nsView: ShimmerView, context: Context) {
        // View updates handled by Auto Layout
    }
}

#endif

// MARK: - Optimized Skeleton Group

#if canImport(UIKit) || canImport(AppKit)

/// Pre-configured optimized skeleton layouts
@available(iOS 16.0, macOS 13.0, *)
public struct DKSkeletonGroupOptimized: View {
    
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
                        DKSkeletonOptimized(
                            width: index == lines - 1 ? 200 : nil,
                            height: 16,
                            shape: .roundedRectangle(radius: 4)
                        )
                    }
                }
                
            case .card:
                VStack(alignment: .leading, spacing: 12) {
                    DKSkeletonOptimized(height: 200, shape: .roundedRectangle(radius: 12))
                    DKSkeletonOptimized(width: 150, height: 20, shape: .roundedRectangle(radius: 4))
                    DKSkeletonOptimized(height: 16, shape: .roundedRectangle(radius: 4))
                    DKSkeletonOptimized(width: 200, height: 16, shape: .roundedRectangle(radius: 4))
                }
                
            case .avatar:
                HStack(spacing: 12) {
                    DKSkeletonOptimized(width: 48, height: 48, shape: .circle)
                    VStack(alignment: .leading, spacing: 8) {
                        DKSkeletonOptimized(width: 120, height: 16, shape: .roundedRectangle(radius: 4))
                        DKSkeletonOptimized(width: 80, height: 12, shape: .roundedRectangle(radius: 4))
                    }
                }
                
            case .listItem:
                HStack(spacing: 12) {
                    DKSkeletonOptimized(width: 40, height: 40, shape: .roundedRectangle(radius: 8))
                    VStack(alignment: .leading, spacing: 6) {
                        DKSkeletonOptimized(width: 150, height: 14, shape: .roundedRectangle(radius: 4))
                        DKSkeletonOptimized(width: 100, height: 12, shape: .roundedRectangle(radius: 4))
                    }
                    Spacer()
                }
            }
        }
    }
}

#endif

// MARK: - View Extension

extension View {
    /// Use optimized skeleton with Core Animation (when available)
    @ViewBuilder
    public func optimizedSkeleton() -> some View {
        #if canImport(UIKit) || canImport(AppKit)
        if #available(iOS 16.0, macOS 13.0, *) {
            self
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Optimized Skeleton Loaders") {
    if #available(iOS 16.0, macOS 13.0, *) {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Hardware Accelerated Skeletons")
                    .textStyle(.headline)
                
                VStack(spacing: 12) {
                    DKSkeletonOptimized(height: 20, shape: .rectangle)
                    DKSkeletonOptimized(width: 60, height: 60, shape: .circle)
                    DKSkeletonOptimized(height: 80, shape: .roundedRectangle(radius: 12))
                }
                
                Text("Pre-configured Layouts")
                    .textStyle(.headline)
                
                DKSkeletonGroupOptimized(layout: .text(lines: 3))
                
                DKSkeletonGroupOptimized(layout: .avatar)
                
                DKSkeletonGroupOptimized(layout: .card)
                
                DKSkeletonGroupOptimized(layout: .listItem)
            }
            .padding()
        }
    } else {
        Text("iOS 16.0+ / macOS 13.0+ gerekli")
            .padding()
    }
}
#endif

