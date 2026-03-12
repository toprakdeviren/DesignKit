import Foundation
import SwiftUI

// MARK: - Performance Benchmark

/// A utility for benchmarking rendering performance
public final class PerformanceBenchmark {
    
    // MARK: - Benchmark Result
    
    public struct Result {
        public let name: String
        public let duration: TimeInterval
        public let iterations: Int
        public let averageTime: TimeInterval
        public let minTime: TimeInterval
        public let maxTime: TimeInterval
        
        public var description: String {
            """
            Benchmark: \(name)
            Total Duration: \(String(format: "%.2f", duration * 1000))ms
            Iterations: \(iterations)
            Average: \(String(format: "%.2f", averageTime * 1000))ms
            Min: \(String(format: "%.2f", minTime * 1000))ms
            Max: \(String(format: "%.2f", maxTime * 1000))ms
            """
        }
    }
    
    // MARK: - Benchmark Execution
    
    /// Run a performance benchmark
    /// - Parameters:
    ///   - name: Name of the benchmark
    ///   - iterations: Number of iterations to run
    ///   - warmup: Number of warmup iterations (not counted)
    ///   - block: The code to benchmark
    /// - Returns: Benchmark result
    public static func measure(
        name: String,
        iterations: Int = 100,
        warmup: Int = 10,
        block: () -> Void
    ) -> Result {
        // Warmup
        for _ in 0..<warmup {
            block()
        }
        
        var times: [TimeInterval] = []
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            let iterationStart = CFAbsoluteTimeGetCurrent()
            block()
            let iterationEnd = CFAbsoluteTimeGetCurrent()
            times.append(iterationEnd - iterationStart)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalDuration = endTime - startTime
        
        let avgTime = times.reduce(0, +) / Double(times.count)
        let minTime = times.min() ?? 0
        let maxTime = times.max() ?? 0
        
        return Result(
            name: name,
            duration: totalDuration,
            iterations: iterations,
            averageTime: avgTime,
            minTime: minTime,
            maxTime: maxTime
        )
    }
    
    /// Compare two implementations
    /// - Parameters:
    ///   - name: Name of the comparison
    ///   - iterations: Number of iterations
    ///   - baseline: Baseline implementation
    ///   - candidate: Candidate implementation
    /// - Returns: Tuple of both results
    public static func compare(
        name: String,
        iterations: Int = 100,
        baseline: () -> Void,
        candidate: () -> Void
    ) -> (baseline: Result, candidate: Result, speedup: Double) {
        let baselineResult = measure(name: "\(name) - Baseline", iterations: iterations, block: baseline)
        let candidateResult = measure(name: "\(name) - Candidate", iterations: iterations, block: candidate)
        
        let speedup = baselineResult.averageTime / candidateResult.averageTime
        
        print("""
        
        ⚡️ Performance Comparison: \(name)
        
        Baseline:
        \(baselineResult.description)
        
        Candidate:
        \(candidateResult.description)
        
        Speedup: \(String(format: "%.2f", speedup))x \(speedup > 1 ? "✅ Faster" : "⚠️ Slower")
        
        """)
        
        return (baselineResult, candidateResult, speedup)
    }
}

// MARK: - FPS Monitor

#if canImport(UIKit)
import UIKit

/// Monitor frames per second in SwiftUI views
@available(iOS 16.0, *)
public final class FPSMonitor: ObservableObject {
    
    @Published public private(set) var currentFPS: Double = 0
    @Published public private(set) var averageFPS: Double = 0
    @Published public private(set) var minFPS: Double = 0
    @Published public private(set) var maxFPS: Double = 0
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var fpsHistory: [Double] = []
    private let maxHistorySize = 60
    
    public init() {}
    
    /// Start monitoring FPS
    public func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Stop monitoring FPS
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }
        
        let elapsed = displayLink.timestamp - lastTimestamp
        lastTimestamp = displayLink.timestamp
        
        let fps = 1.0 / elapsed
        
        fpsHistory.append(fps)
        if fpsHistory.count > maxHistorySize {
            fpsHistory.removeFirst()
        }
        
        currentFPS = fps
        averageFPS = fpsHistory.reduce(0, +) / Double(fpsHistory.count)
        minFPS = fpsHistory.min() ?? 0
        maxFPS = fpsHistory.max() ?? 0
        
        frameCount += 1
    }
    
    /// Reset statistics
    public func reset() {
        fpsHistory.removeAll()
        frameCount = 0
        currentFPS = 0
        averageFPS = 0
        minFPS = 0
        maxFPS = 0
    }
    
    deinit {
        stop()
    }
}
#elseif canImport(AppKit)
import AppKit

/// Monitor frames per second in SwiftUI views (macOS stub)
@available(macOS 13.0, *)
public final class FPSMonitor: ObservableObject {
    
    @Published public private(set) var currentFPS: Double = 60.0
    @Published public private(set) var averageFPS: Double = 60.0
    @Published public private(set) var minFPS: Double = 60.0
    @Published public private(set) var maxFPS: Double = 60.0
    
    public init() {}
    
    /// Start monitoring FPS (not available on macOS 13)
    public func start() {
        // CVDisplayLink alternative would be needed for macOS < 14
        print("⚠️ FPS monitoring requires macOS 14.0+ or use CVDisplayLink")
    }
    
    /// Stop monitoring FPS
    public func stop() {}
    
    /// Reset statistics
    public func reset() {}
}
#else
/// FPS Monitor stub for unsupported platforms
public final class FPSMonitor: ObservableObject {
    @Published public private(set) var currentFPS: Double = 0
    @Published public private(set) var averageFPS: Double = 0
    @Published public private(set) var minFPS: Double = 0
    @Published public private(set) var maxFPS: Double = 0
    
    public init() {}
    public func start() {}
    public func stop() {}
    public func reset() {}
}
#endif

// MARK: - FPS Overlay View

#if canImport(UIKit) || canImport(AppKit)
/// Overlay view to display FPS in debug builds
@available(iOS 16.0, macOS 13.0, *)
public struct FPSOverlay: View {
    @StateObject private var monitor = FPSMonitor()
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FPS: \(Int(monitor.currentFPS))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(fpsColor)
            
            Text("Avg: \(Int(monitor.averageFPS))")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary)
            
            Text("Min: \(Int(monitor.minFPS))")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .onAppear {
            monitor.start()
        }
        .onDisappear {
            monitor.stop()
        }
    }
    
    private var fpsColor: Color {
        if monitor.currentFPS >= 55 {
            return .green
        } else if monitor.currentFPS >= 30 {
            return .yellow
        } else {
            return .red
        }
    }
}
#endif

// MARK: - View Extension

#if canImport(SwiftUI)
extension View {
    /// Show FPS overlay in debug builds
    @ViewBuilder
    public func showFPS(_ enabled: Bool = true) -> some View {
        #if DEBUG && (canImport(UIKit) || canImport(AppKit))
        if enabled {
            if #available(iOS 16.0, macOS 13.0, *) {
                overlay(
                    FPSOverlay()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding()
                )
            } else {
                self
            }
        } else {
            self
        }
        #else
        self
        #endif
    }
}
#endif

// MARK: - Memory Usage Monitor

/// Monitor memory usage
public final class MemoryMonitor {
    
    public struct MemoryInfo {
        public let used: UInt64        // Bytes
        public let available: UInt64   // Bytes
        public let total: UInt64       // Bytes
        
        public var usedMB: Double {
            Double(used) / 1024.0 / 1024.0
        }
        
        public var availableMB: Double {
            Double(available) / 1024.0 / 1024.0
        }
        
        public var totalMB: Double {
            Double(total) / 1024.0 / 1024.0
        }
        
        public var description: String {
            """
            Memory Usage:
            Used: \(String(format: "%.1f", usedMB)) MB
            Available: \(String(format: "%.1f", availableMB)) MB
            Total: \(String(format: "%.1f", totalMB)) MB
            """
        }
    }
    
    /// Get current memory usage
    public static func currentUsage() -> MemoryInfo? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return nil
        }
        
        let used = UInt64(info.resident_size)
        
        // Get physical memory
        var size: UInt64 = 0
        var sizeSize = MemoryLayout<UInt64>.size
        let result2 = sysctlbyname("hw.memsize", &size, &sizeSize, nil, 0)
        
        let total = result2 == 0 ? size : 0
        let available = total > used ? total - used : 0
        
        return MemoryInfo(used: used, available: available, total: total)
    }
}

