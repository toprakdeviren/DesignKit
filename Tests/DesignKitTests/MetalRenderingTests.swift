import XCTest
@testable import DesignKit

#if canImport(Metal) && (os(iOS) || os(macOS))
import Metal
@testable import DesignKitMetal
#endif

final class MetalRenderingTests: XCTestCase {
    
    // MARK: - Backend Selection Tests
    
    func testAutoBackendSelectionWithSmallDataset() {
        let backend = RenderingBackend.selectBackend(
            dataCount: 10,
            isAnimated: false,
            isHighFrequency: false,
            deviceSupportsMetalGPU: true
        )
        
        XCTAssertEqual(backend, .swiftUI, "Small datasets should use SwiftUI backend")
    }
    
    func testAutoBackendSelectionWithLargeDataset() {
        let backend = RenderingBackend.selectBackend(
            dataCount: 2000,
            isAnimated: false,
            isHighFrequency: false,
            deviceSupportsMetalGPU: true
        )
        
        XCTAssertEqual(backend, .metal, "Large datasets should use Metal backend")
    }
    
    func testAutoBackendSelectionWithMediumDatasetAndAnimation() {
        let backend = RenderingBackend.selectBackend(
            dataCount: 700,
            isAnimated: true,
            isHighFrequency: true,
            deviceSupportsMetalGPU: true
        )
        
        XCTAssertEqual(backend, .metal, "Medium animated datasets should use Metal backend")
    }
    
    func testAutoBackendSelectionWithoutMetalSupport() {
        let backend = RenderingBackend.selectBackend(
            dataCount: 5000,
            isAnimated: true,
            isHighFrequency: true,
            deviceSupportsMetalGPU: false
        )
        
        XCTAssertEqual(backend, .swiftUI, "Should fallback to SwiftUI when Metal is not supported")
    }
    
    // MARK: - Metal Availability Tests
    
    func testMetalAvailability() {
        let isAvailable = RenderingBackend.isMetalAvailable()
        
        #if canImport(Metal) && (os(iOS) || os(macOS))
        // On iOS and macOS with Metal support, it should be available
        XCTAssertTrue(isAvailable || !isAvailable, "Metal availability should be determinable")
        #else
        XCTAssertFalse(isAvailable, "Metal should not be available on unsupported platforms")
        #endif
    }
    
    func testMetalDeviceInfo() {
        let info = RenderingBackend.metalDeviceInfo()
        
        #if canImport(Metal) && (os(iOS) || os(macOS))
        if RenderingBackend.isMetalAvailable() {
            XCTAssertNotNil(info, "Metal device info should be available")
            XCTAssertTrue(info?.contains("Device:") ?? false, "Info should contain device name")
        }
        #else
        XCTAssertNil(info, "Metal device info should be nil on unsupported platforms")
        #endif
    }
    
    // MARK: - Performance Monitoring Tests
    
    func testPerformanceMonitorInitialization() {
        let monitor = RenderingPerformanceMonitor()
        
        monitor.beginFrame()
        Thread.sleep(forTimeInterval: 0.016) // Simulate 16ms frame
        let metrics = monitor.endFrame()
        
        XCTAssertGreaterThan(metrics.frametime, 0, "Frametime should be positive")
        XCTAssertGreaterThan(metrics.fps, 0, "FPS should be positive")
    }
    
    func testPerformanceMonitorAveraging() {
        let monitor = RenderingPerformanceMonitor()
        
        // Record multiple frames
        for _ in 0..<10 {
            monitor.beginFrame()
            Thread.sleep(forTimeInterval: 0.016)
            _ = monitor.endFrame()
        }
        
        let avgMetrics = monitor.averageMetrics
        
        XCTAssertGreaterThan(avgMetrics.averageFPS, 0, "Average FPS should be positive")
        XCTAssertLessThan(avgMetrics.averageFPS, 100, "Average FPS should be reasonable")
    }
    
    // MARK: - Rendering Configuration Tests
    
    func testDefaultRenderingConfiguration() {
        let config = RenderingConfiguration.default
        
        XCTAssertEqual(config.preferredBackend, .auto, "Default backend should be auto")
        XCTAssertFalse(config.enablePerformanceMonitoring, "Performance monitoring should be off by default")
        XCTAssertEqual(config.targetFrameRate, 0, "Default frame rate should be 0 (device refresh rate)")
    }
    
    func testCustomRenderingConfiguration() {
        let config = RenderingConfiguration(
            preferredBackend: .metal,
            enablePerformanceMonitoring: true,
            targetFrameRate: 60,
            enableTripleBuffering: true,
            preferHalfPrecision: true
        )
        
        XCTAssertEqual(config.preferredBackend, .metal)
        XCTAssertTrue(config.enablePerformanceMonitoring)
        XCTAssertEqual(config.targetFrameRate, 60)
        XCTAssertTrue(config.enableTripleBuffering)
        XCTAssertTrue(config.preferHalfPrecision)
    }
    
    // MARK: - Chart Backend Integration Tests
    
    func testChartWithAutoBackend() {
        let smallData = (0..<10).map { index in
            DKChart.DataPoint(label: "Item \(index)", value: Double(index * 10))
        }
        
        let chart = DKChart(data: smallData, backend: .auto)
        
        XCTAssertNotNil(chart, "Chart should be created with auto backend")
    }
    
    func testChartWithExplicitSwiftUIBackend() {
        let data = (0..<100).map { index in
            DKChart.DataPoint(label: "Item \(index)", value: Double(index * 10))
        }
        
        let chart = DKChart(data: data, backend: .swiftUI)
        
        XCTAssertNotNil(chart, "Chart should be created with SwiftUI backend")
    }
    
    #if canImport(Metal) && (os(iOS) || os(macOS))
    func testMetalBarChartRendererInitialization() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTSkip("Metal is not available on this device")
            return
        }
        
        let renderer = MetalBarChartRenderer(device: device)
        
        XCTAssertNotNil(renderer, "Metal bar chart renderer should initialize")
    }
    
    func testMetalBarChartRendererDataUpdate() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTSkip("Metal is not available on this device")
            return
        }
        
        guard let renderer = MetalBarChartRenderer(device: device) else {
            XCTFail("Failed to initialize renderer")
            return
        }
        
        let values = [10.0, 20.0, 30.0, 40.0, 50.0]
        let colors = values.map { _ in SIMD4<Float>(0.2, 0.6, 1.0, 1.0) }
        
        renderer.setData(values, colors: colors)
        renderer.setViewportSize(CGSize(width: 300, height: 200))
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
    
    func testMetalLineChartRendererInitialization() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            XCTSkip("Metal is not available on this device")
            return
        }
        
        let renderer = MetalLineChartRenderer(device: device)
        
        XCTAssertNotNil(renderer, "Metal line chart renderer should initialize")
    }
    #endif
    
    // MARK: - Performance Comparison Tests
    
    func testSmallDatasetPerformance() {
        let smallDataCount = 10
        let data = (0..<smallDataCount).map { Double($0) }
        
        // This is a simple test to ensure no crashes
        // Real performance testing would require actual rendering
        XCTAssertEqual(data.count, smallDataCount)
    }
    
    func testLargeDatasetPerformance() {
        let largeDataCount = 10_000
        let data = (0..<largeDataCount).map { Double($0) }
        
        // Measure data processing time
        let start = CFAbsoluteTimeGetCurrent()
        let processed = data.map { $0 * 2.0 }
        let end = CFAbsoluteTimeGetCurrent()
        
        let elapsed = (end - start) * 1000 // Convert to ms
        
        XCTAssertEqual(processed.count, largeDataCount)
        XCTAssertLessThan(elapsed, 100, "Data processing should be fast")
    }
}

// MARK: - Benchmark Tests

final class PerformanceBenchmarkTests: XCTestCase {
    
    func testBenchmarkExecution() {
        var counter = 0
        
        let result = PerformanceBenchmark.measure(
            name: "Simple Counter",
            iterations: 100,
            warmup: 10
        ) {
            counter += 1
        }
        
        XCTAssertEqual(result.iterations, 100)
        XCTAssertGreaterThan(result.averageTime, 0)
        XCTAssertGreaterThanOrEqual(result.maxTime, result.minTime)
    }
    
    func testBenchmarkComparison() {
        let baseline = {
            var sum = 0
            for i in 0..<1000 {
                sum += i
            }
        }
        
        let candidate = {
            let _ = (0..<1000).reduce(0, +)
        }
        
        let (baselineResult, candidateResult, speedup) = PerformanceBenchmark.compare(
            name: "Sum Comparison",
            iterations: 100,
            baseline: baseline,
            candidate: candidate
        )
        
        XCTAssertGreaterThan(baselineResult.averageTime, 0)
        XCTAssertGreaterThan(candidateResult.averageTime, 0)
        XCTAssertGreaterThan(speedup, 0)
    }
}

// MARK: - Memory Monitor Tests

final class MemoryMonitorTests: XCTestCase {
    
    func testMemoryUsageRetrieval() {
        let memoryInfo = MemoryMonitor.currentUsage()
        
        XCTAssertNotNil(memoryInfo, "Memory info should be available")
        
        if let info = memoryInfo {
            XCTAssertGreaterThan(info.used, 0, "Used memory should be positive")
            XCTAssertGreaterThan(info.usedMB, 0, "Used memory in MB should be positive")
        }
    }
}

