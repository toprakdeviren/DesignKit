import Foundation

#if canImport(Metal)
import Metal
#endif

// MARK: - Rendering Backend

/// Defines the rendering backend for components
public enum RenderingBackend {
    /// Automatically select backend based on heuristics
    case auto
    
    /// Use SwiftUI native rendering (default)
    case swiftUI
    
    /// Use Metal-accelerated rendering (requires DesignKitMetal)
    case metal
    
    // MARK: - Auto Selection
    
    /// Automatically select the best backend based on data characteristics and device capabilities
    /// - Parameters:
    ///   - dataCount: Number of data points to render
    ///   - isAnimated: Whether the rendering includes continuous animation
    ///   - isHighFrequency: Whether updates happen at high frequency (>30fps)
    ///   - deviceSupportsMetalGPU: Whether the device has Metal GPU support
    /// - Returns: The recommended backend
    public static func selectBackend(
        dataCount: Int,
        isAnimated: Bool = false,
        isHighFrequency: Bool = false,
        deviceSupportsMetalGPU: Bool = true
    ) -> RenderingBackend {
        #if canImport(Metal) && (os(iOS) || os(macOS))
        // Check device Metal support
        guard deviceSupportsMetalGPU, MTLCreateSystemDefaultDevice() != nil else {
            return .swiftUI
        }
        
        // Heuristic thresholds
        let heavyDataThreshold = 1_000
        let mediumDataThreshold = 500
        
        // High data count scenarios
        if dataCount > heavyDataThreshold {
            return .metal
        }
        
        // Medium data with animation and high frequency
        if dataCount > mediumDataThreshold && isAnimated && isHighFrequency {
            return .metal
        }
        
        // Medium data with continuous animation
        if dataCount > mediumDataThreshold && isAnimated {
            return .metal
        }
        
        #endif
        
        // Default to SwiftUI for other cases
        return .swiftUI
    }
    
    // MARK: - Device Capabilities
    
    /// Check if Metal is available on the current device
    public static func isMetalAvailable() -> Bool {
        #if canImport(Metal) && (os(iOS) || os(macOS))
        return MTLCreateSystemDefaultDevice() != nil
        #else
        return false
        #endif
    }
    
    /// Get Metal device info for diagnostics
    public static func metalDeviceInfo() -> String? {
        #if canImport(Metal) && (os(iOS) || os(macOS))
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        var info = "Device: \(device.name)\n"
        
        #if os(macOS)
        info += "Low Power: \(device.isLowPower)\n"
        info += "Headless: \(device.isHeadless)\n"
        #endif
        
        info += "Registry ID: \(device.registryID)"
        
        return info
        #else
        return nil
        #endif
    }
}

// MARK: - Performance Monitoring

/// Performance metrics for rendering
public struct RenderingMetrics {
    public let frametime: Double  // milliseconds
    public let fps: Double
    public let cpuTime: Double    // milliseconds
    public let gpuTime: Double    // milliseconds (if available)
    
    public init(frametime: Double, fps: Double, cpuTime: Double, gpuTime: Double = 0) {
        self.frametime = frametime
        self.fps = fps
        self.cpuTime = cpuTime
        self.gpuTime = gpuTime
    }
}

/// Performance monitor for tracking rendering performance
public final class RenderingPerformanceMonitor {
    private var frameStartTime: CFAbsoluteTime = 0
    private var frameTimes: [Double] = []
    private let maxSamples: Int = 60
    
    public init() {}
    
    /// Mark the start of a frame
    public func beginFrame() {
        frameStartTime = CFAbsoluteTimeGetCurrent()
    }
    
    /// Mark the end of a frame and record metrics
    public func endFrame() -> RenderingMetrics {
        let frameEndTime = CFAbsoluteTimeGetCurrent()
        let frametime = (frameEndTime - frameStartTime) * 1000 // ms
        
        frameTimes.append(frametime)
        if frameTimes.count > maxSamples {
            frameTimes.removeFirst()
        }
        
        let avgFrametime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        let fps = 1000.0 / avgFrametime
        
        return RenderingMetrics(
            frametime: frametime,
            fps: fps,
            cpuTime: frametime,
            gpuTime: 0
        )
    }
    
    /// Get average metrics over recent frames
    public var averageMetrics: RenderingMetrics {
        guard !frameTimes.isEmpty else {
            return RenderingMetrics(frametime: 0, fps: 0, cpuTime: 0, gpuTime: 0)
        }
        
        let avgFrametime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        let fps = 1000.0 / avgFrametime
        
        return RenderingMetrics(
            frametime: avgFrametime,
            fps: fps,
            cpuTime: avgFrametime,
            gpuTime: 0
        )
    }
    
    /// Reset all metrics
    public func reset() {
        frameTimes.removeAll()
    }
}

// MARK: - Rendering Configuration

/// Global rendering configuration
public struct RenderingConfiguration {
    /// Preferred rendering backend
    public var preferredBackend: RenderingBackend = .auto
    
    /// Enable performance monitoring
    public var enablePerformanceMonitoring: Bool = false
    
    /// Frame rate target (0 = device refresh rate)
    public var targetFrameRate: Int = 0
    
    /// Enable triple buffering for Metal
    public var enableTripleBuffering: Bool = true
    
    /// Use half precision (float16) when possible
    public var preferHalfPrecision: Bool = true
    
    public init(
        preferredBackend: RenderingBackend = .auto,
        enablePerformanceMonitoring: Bool = false,
        targetFrameRate: Int = 0,
        enableTripleBuffering: Bool = true,
        preferHalfPrecision: Bool = true
    ) {
        self.preferredBackend = preferredBackend
        self.enablePerformanceMonitoring = enablePerformanceMonitoring
        self.targetFrameRate = targetFrameRate
        self.enableTripleBuffering = enableTripleBuffering
        self.preferHalfPrecision = preferHalfPrecision
    }
    
    /// Default configuration
    public static let `default` = RenderingConfiguration()
}

// MARK: - Environment Key

private struct RenderingConfigurationKey: EnvironmentKey {
    static let defaultValue = RenderingConfiguration.default
}

extension EnvironmentValues {
    public var renderingConfiguration: RenderingConfiguration {
        get { self[RenderingConfigurationKey.self] }
        set { self[RenderingConfigurationKey.self] = newValue }
    }
}

// MARK: - View Extension

#if canImport(SwiftUI)
import SwiftUI

extension View {
    /// Set rendering configuration for this view and its children
    public func renderingConfiguration(_ configuration: RenderingConfiguration) -> some View {
        environment(\.renderingConfiguration, configuration)
    }
    
    /// Set preferred rendering backend
    public func preferredRenderingBackend(_ backend: RenderingBackend) -> some View {
        var config = RenderingConfiguration.default
        config.preferredBackend = backend
        return environment(\.renderingConfiguration, config)
    }
}
#endif

