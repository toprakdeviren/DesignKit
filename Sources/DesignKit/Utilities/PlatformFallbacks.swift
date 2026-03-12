import SwiftUI

// MARK: - Platform-Specific Fallbacks

/// Provides graceful fallbacks for features not available on all platforms
public struct PlatformCapabilities {
    
    // MARK: - Metal Support
    
    /// Check if Metal is available on current platform
    public static var supportsMetalRendering: Bool {
        #if os(iOS) || os(macOS)
        return RenderingBackend.isMetalAvailable()
        #else
        return false
        #endif
    }
    
    /// Check if Core Animation is available
    public static var supportsCoreAnimation: Bool {
        #if os(iOS) || os(macOS) || os(tvOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Check if Core Image is available
    public static var supportsCoreImage: Bool {
        #if canImport(CoreImage) && (os(iOS) || os(macOS) || os(tvOS))
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - FPS Monitoring
    
    /// Check if FPS monitoring is available
    public static var supportsFPSMonitoring: Bool {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            return true
        }
        return false
        #elseif os(macOS)
        if #available(macOS 14.0, *) {
            return true
        }
        return false
        #else
        return false
        #endif
    }
    
    // MARK: - Platform Info
    
    public static var platformName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
    
    public static var isLowPowerDevice: Bool {
        #if os(watchOS)
        return true
        #elseif os(tvOS)
        return false  // tvOS has decent power
        #elseif os(macOS)
        #if canImport(Metal)
        return MTLCreateSystemDefaultDevice()?.isLowPower ?? false
        #else
        return false
        #endif
        #else
        // iOS doesn't expose isLowPower property
        return false
        #endif
    }
    
    // MARK: - Recommended Backend
    
    public static func recommendedBackend(for dataCount: Int, animated: Bool = false) -> RenderingBackend {
        #if os(iOS) || os(macOS)
        // Use auto-selection on platforms with Metal support
        return RenderingBackend.selectBackend(
            dataCount: dataCount,
            isAnimated: animated,
            deviceSupportsMetalGPU: supportsMetalRendering
        )
        #else
        // Always use SwiftUI on watchOS/tvOS
        return .swiftUI
        #endif
    }
}

// MARK: - Platform-Adaptive Chart

/// Chart wrapper that automatically adapts to platform capabilities
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct DKChartAdaptive: View {
    
    private let title: String?
    private let data: [DKChart.DataPoint]
    private let type: DKChart.ChartType
    private let showLegend: Bool
    private let animated: Bool
    
    public init(
        title: String? = nil,
        data: [DKChart.DataPoint],
        type: DKChart.ChartType = .bar,
        showLegend: Bool = true,
        animated: Bool = true
    ) {
        self.title = title
        self.data = data
        self.type = type
        self.showLegend = showLegend
        self.animated = animated
    }
    
    public var body: some View {
        let backend = PlatformCapabilities.recommendedBackend(for: data.count, animated: animated)
        
        DKChart(
            title: title,
            data: adaptedData,
            type: type,
            showLegend: showLegend,
            animated: animated,
            backend: backend
        )
        .overlay(platformBadge, alignment: .topLeading)
    }
    
    // Adapt data for low-power devices
    private var adaptedData: [DKChart.DataPoint] {
        #if os(watchOS)
        // Limit data points on watchOS
        let maxPoints = 20
        if data.count > maxPoints {
            return Array(data.prefix(maxPoints))
        }
        #endif
        return data
    }
    
    // Show platform indicator in debug
    @ViewBuilder
    private var platformBadge: some View {
        #if DEBUG
        Text(PlatformCapabilities.platformName)
            .font(.system(size: 8))
            .padding(4)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(4)
            .padding(4)
        #else
        EmptyView()
        #endif
    }
}

// MARK: - Platform-Specific Performance Hints

/// Performance optimization hints for different platforms
public struct PlatformOptimizationHints {
    
    /// Recommended max data points for smooth performance
    public static var recommendedMaxDataPoints: Int {
        #if os(watchOS)
        return 50
        #elseif os(tvOS)
        return 500
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone ? 1000 : 5000
        #elseif os(macOS)
        return 10_000
        #else
        return 1000
        #endif
    }
    
    /// Recommended animation duration
    public static var recommendedAnimationDuration: TimeInterval {
        #if os(watchOS)
        return 0.5  // Faster animations on watch
        #else
        return 1.0
        #endif
    }
    
    /// Should use reduced motion
    public static var shouldUseReducedMotion: Bool {
        #if os(iOS)
        return UIAccessibility.isReduceMotionEnabled
        #elseif os(macOS)
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #elseif os(watchOS)
        return WKAccessibility.isReduceMotionEnabled
        #else
        return false
        #endif
    }
    
    /// Recommended frame rate
    public static var recommendedFrameRate: Int {
        #if os(watchOS)
        return 30  // Lower frame rate on watch
        #elseif os(tvOS)
        return 60  // TV supports 60fps
        #else
        return 60
        #endif
    }
}

// MARK: - Fallback Components

#if os(watchOS) || os(tvOS)

/// Simplified skeleton for watchOS/tvOS
@available(watchOS 9.0, tvOS 16.0, *)
public struct DKSkeletonSimple: View {
    
    private let width: CGFloat?
    private let height: CGFloat
    private let shape: SkeletonShape
    
    @Environment(\.designKitTheme) private var theme
    @State private var isAnimating = false
    
    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        shape: SkeletonShape = .rectangle
    ) {
        self.width = width
        self.height = height
        self.shape = shape
    }
    
    public var body: some View {
        // Simple pulsing animation (no gradient shimmer)
        maskShape
            .fill(theme.colorTokens.neutral200)
            .frame(width: width, height: height)
            .opacity(isAnimating ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
    
    @ViewBuilder
    private var maskShape: some Shape {
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

#endif

// MARK: - View Extensions

extension View {
    
    /// Apply platform-appropriate optimizations
    @ViewBuilder
    public func platformOptimized() -> some View {
        #if os(watchOS)
        self
            .animation(.easeInOut(duration: PlatformOptimizationHints.recommendedAnimationDuration), value: UUID())
        #elseif os(tvOS)
        self
            .focusable(true)
        #else
        self
        #endif
    }
    
    /// Show performance overlay (debug only)
    @ViewBuilder
    public func showPlatformInfo(_ enabled: Bool = true) -> some View {
        #if DEBUG
        if enabled {
            overlay(
                VStack(alignment: .leading, spacing: 2) {
                    Text("Platform: \(PlatformCapabilities.platformName)")
                    Text("Metal: \(PlatformCapabilities.supportsMetalRendering ? "✅" : "❌")")
                    Text("Max Points: \(PlatformOptimizationHints.recommendedMaxDataPoints)")
                    Text("FPS Target: \(PlatformOptimizationHints.recommendedFrameRate)")
                }
                .font(.system(size: 8))
                .padding(4)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(8)
            )
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - Platform-Specific Imports

#if os(watchOS)
import WatchKit

extension PlatformOptimizationHints {
    /// WatchKit-specific optimizations
    public static var watchScreenSize: CGSize {
        return WKInterfaceDevice.current().screenBounds.size
    }
    
    public static var isWatchSeries7OrLater: Bool {
        // Check screen size as proxy
        let size = WKInterfaceDevice.current().screenBounds.size
        return size.width >= 184  // Series 7+ has 41mm (184px) or 45mm (198px)
    }
}
#endif

#if os(tvOS)
extension PlatformOptimizationHints {
    /// tvOS-specific optimizations
    public static var isFocusEngineEnabled: Bool {
        return true  // Always true on tvOS
    }
}
#endif

