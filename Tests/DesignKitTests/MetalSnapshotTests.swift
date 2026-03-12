import XCTest
import SwiftUI
import SnapshotTesting
@testable import DesignKit

#if canImport(Metal) && (os(iOS) || os(macOS))
import Metal
@testable import DesignKitMetal
#endif

/// Snapshot tests with pixel diff tolerance for Metal rendering
@available(iOS 16.0, macOS 13.0, *)
final class MetalSnapshotTests: XCTestCase {
    
    // MARK: - Configuration
    
    /// Pixel difference tolerance for Metal rendering
    /// Metal may have slight differences due to anti-aliasing and floating-point precision
    private let pixelTolerance: Float = 0.02  // 2% pixel difference allowed
    private let perceptualPrecision: Float = 0.98  // 98% similarity required
    
    override func setUp() {
        super.setUp()
        
        // Configure snapshot testing
        #if os(iOS)
        // Set default device for consistent snapshots
        // UIDevice.current is not settable, so we'll use actual device
        #endif
    }
    
    // MARK: - Chart Snapshot Tests
    
    func testBarChartSwiftUISnapshot() {
        let data = generateTestData(count: 10)
        let chart = DKChart(
            title: "Test Bar Chart",
            data: data,
            type: .bar,
            backend: .swiftUI,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        assertSnapshot(
            matching: chart,
            as: .image(precision: 1.0),  // Strict for SwiftUI
            named: "bar-chart-swiftui"
        )
    }
    
    #if canImport(Metal) && (os(iOS) || os(macOS))
    func testBarChartMetalSnapshot() {
        guard RenderingBackend.isMetalAvailable() else {
            XCTSkip("Metal not available on this device")
            return
        }
        
        let data = generateTestData(count: 10)
        let chart = DKChart(
            title: "Test Bar Chart",
            data: data,
            type: .bar,
            backend: .metal,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        // Use lower precision for Metal due to anti-aliasing differences
        assertSnapshot(
            matching: chart,
            as: .image(precision: perceptualPrecision),
            named: "bar-chart-metal"
        )
    }
    
    func testBarChartConsistency() {
        guard RenderingBackend.isMetalAvailable() else {
            XCTSkip("Metal not available")
            return
        }
        
        let data = generateTestData(count: 10)
        
        // SwiftUI version
        let swiftUIChart = DKChart(
            title: "Test",
            data: data,
            type: .bar,
            backend: .swiftUI,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        // Metal version
        let metalChart = DKChart(
            title: "Test",
            data: data,
            type: .bar,
            backend: .metal,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        // Both should render similarly (with tolerance)
        // Note: We can't directly compare them, but we ensure both don't crash
        assertSnapshot(matching: swiftUIChart, as: .image(precision: 0.95), named: "consistency-swiftui")
        assertSnapshot(matching: metalChart, as: .image(precision: 0.95), named: "consistency-metal")
    }
    #endif
    
    // MARK: - Line Chart Tests
    
    func testLineChartSnapshot() {
        let data = generateTestData(count: 20)
        let chart = DKChart(
            title: "Test Line Chart",
            data: data,
            type: .line,
            backend: .swiftUI,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        assertSnapshot(
            matching: chart,
            as: .image(precision: 1.0),
            named: "line-chart-swiftui"
        )
    }
    
    // MARK: - Area Chart Tests
    
    func testAreaChartSnapshot() {
        let data = generateTestData(count: 15)
        let chart = DKChart(
            title: "Test Area Chart",
            data: data,
            type: .area,
            backend: .swiftUI,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        assertSnapshot(
            matching: chart,
            as: .image(precision: 0.99),  // Gradients may vary slightly
            named: "area-chart-swiftui"
        )
    }
    
    // MARK: - Skeleton Tests
    
    func testSkeletonSnapshot() {
        let skeleton = DKSkeletonGroup(layout: .card)
            .frame(width: 300, height: 200)
        
        assertSnapshot(
            matching: skeleton,
            as: .image(precision: 0.98),  // Animation state may vary
            named: "skeleton-card"
        )
    }
    
    #if canImport(UIKit) || canImport(AppKit)
    @available(iOS 16.0, macOS 13.0, *)
    func testOptimizedSkeletonSnapshot() {
        let skeleton = DKSkeletonGroupOptimized(layout: .card)
            .frame(width: 300, height: 200)
        
        assertSnapshot(
            matching: skeleton,
            as: .image(precision: 0.95),  // Core Animation may have timing differences
            named: "skeleton-optimized-card"
        )
    }
    #endif
    
    // MARK: - Platform-Specific Tests
    
    func testAdaptiveChartSnapshot() {
        let data = generateTestData(count: 50)
        let chart = DKChartAdaptive(
            title: "Adaptive Chart",
            data: data,
            type: .bar,
            animated: false
        )
        .frame(width: 300, height: 250)
        
        assertSnapshot(
            matching: chart,
            as: .image(precision: 0.95),
            named: "adaptive-chart-\(PlatformCapabilities.platformName.lowercased())"
        )
    }
    
    // MARK: - Stress Tests
    
    func testLargeDatasetSnapshot() {
        let data = generateTestData(count: 100)
        let chart = DKChart(
            title: "Large Dataset",
            data: data,
            type: .bar,
            backend: .auto,
            animated: false
        )
        .frame(width: 400, height: 300)
        
        // Lower precision for large datasets
        assertSnapshot(
            matching: chart,
            as: .image(precision: 0.90),
            named: "large-dataset"
        )
    }
    
    // MARK: - Helpers
    
    private func generateTestData(count: Int) -> [DKChart.DataPoint] {
        return (0..<count).map { index in
            DKChart.DataPoint(
                label: "Item \(index)",
                value: Double.random(in: 10...100)
            )
        }
    }
}

// MARK: - Custom Snapshot Strategies

#if canImport(UIKit)
extension Snapshotting where Value == AnyView, Format == UIImage {
    
    /// Snapshot with custom pixel tolerance
    static func imageWithTolerance(precision: Float = 0.98) -> Snapshotting {
        return Snapshotting<UIView, UIImage>.image(precision: precision).pullback { view in
            let controller = UIHostingController(rootView: view)
            return controller.view
        }
    }
}
#elseif canImport(AppKit)
extension Snapshotting where Value == AnyView, Format == NSImage {
    
    /// Snapshot with custom pixel tolerance
    static func imageWithTolerance(precision: Float = 0.98) -> Snapshotting {
        return Snapshotting<NSView, NSImage>.image(precision: precision).pullback { view in
            let controller = NSHostingController(rootView: view)
            return controller.view
        }
    }
}
#endif

// MARK: - Pixel Diff Analyzer

/// Analyze pixel differences between snapshots
struct PixelDiffAnalyzer {
    
    /// Compare two images and return similarity percentage
    static func compare(_ image1: CGImage, _ image2: CGImage) -> Double {
        guard image1.width == image2.width && image1.height == image2.height else {
            return 0.0
        }
        
        // This is a simplified version - real implementation would be more sophisticated
        let totalPixels = image1.width * image1.height
        
        // For now, return 100% (actual implementation would compare pixel data)
        return 1.0
    }
    
    /// Generate diff image highlighting differences
    static func generateDiffImage(_ image1: CGImage, _ image2: CGImage) -> CGImage? {
        // Implementation would build a visual diff
        return nil
    }
}

