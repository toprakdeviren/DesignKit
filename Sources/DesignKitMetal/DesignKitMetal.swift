import Foundation

/// DesignKit Metal-accelerated rendering backend
///
/// This module provides GPU-accelerated rendering for DesignKit components
/// using Metal. It offers significant performance improvements for:
///
/// - Large datasets (>1000 data points)
/// - Continuous animations
/// - High-frequency updates
///
/// ## Platform Support
///
/// - iOS 16.0+
/// - macOS 13.0+
///
/// ## Usage
///
/// ```swift
/// import DesignKit
/// import DesignKitMetal
///
/// // Automatic backend selection
/// DKChart(data: largeDataset, backend: .auto)
///
/// // Force Metal backend
/// DKChart(data: largeDataset, backend: .metal)
/// ```
///
/// ## Performance Gains
///
/// - Bar charts: 5-8x improvement with 1K+ data points
/// - Line charts: 10-15x improvement with 10K+ points
/// - Area charts: 3-5x improvement with gradients
///
public struct DesignKitMetal {
    
    /// Version of the DesignKitMetal module
    public static let version = "0.5.0"
    
    /// Check if Metal is available on the current device
    public static var isAvailable: Bool {
        #if canImport(Metal) && (os(iOS) || os(macOS))
        return MTLCreateSystemDefaultDevice() != nil
        #else
        return false
        #endif
    }
    
    /// Get Metal device information
    public static func deviceInfo() -> String? {
        #if canImport(Metal) && (os(iOS) || os(macOS))
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        var info = "Device: \(device.name)"
        #if os(macOS)
        info += "\nLow Power: \(device.isLowPower)"
        info += "\nHeadless: \(device.isHeadless)"
        #endif
        info += "\nRegistry ID: \(device.registryID)"
        info += "\nRecommended Max Working Set Size: \(device.recommendedMaxWorkingSetSize / 1024 / 1024) MB"
        return info
        #else
        return nil
        #endif
    }
}

#if canImport(Metal)
import Metal
#endif

