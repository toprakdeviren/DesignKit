import SwiftUI
import MetalKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Metal Chart View

/// SwiftUI wrapper for Metal-accelerated charts
public struct MetalChartView: View {
    
    // MARK: - Chart Type
    
    public enum ChartType {
        case bar
        case line
        case area
    }
    
    // MARK: - Properties
    
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let type: ChartType
    let animated: Bool
    
    @State private var animationProgress: Float = 0.0
    
    // MARK: - Initialization
    
    public init(
        data: [Double],
        colors: [SIMD4<Float>]? = nil,
        type: ChartType = .bar,
        animated: Bool = true
    ) {
        self.data = data
        self.colors = colors
        self.type = type
        self.animated = animated
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            switch type {
            case .bar:
                MetalBarChartViewRepresentable(
                    data: data,
                    colors: colors,
                    animationProgress: animationProgress
                )
            case .line:
                MetalLineChartViewRepresentable(
                    data: data,
                    colors: colors,
                    animationProgress: animationProgress
                )
            case .area:
                MetalAreaChartViewRepresentable(
                    data: data,
                    colors: colors,
                    animationProgress: animationProgress
                )
            }
        }
        .onAppear {
            if animated {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }
}

// MARK: - Bar Chart Representable

#if canImport(UIKit)

struct MetalBarChartViewRepresentable: UIViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        // Set up renderer
        if let renderer = MetalBarChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            // Set initial data
            renderer.setData(data, colors: colors)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateUIView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        // Update data and animation
        renderer.setData(data, colors: colors)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay()
    }
    
    class Coordinator {
        var renderer: MetalBarChartRenderer?
    }
}

struct MetalLineChartViewRepresentable: UIViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        // Set up renderer
        if let renderer = MetalLineChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            // Convert data to points (will be properly scaled in renderer)
            let points = data.enumerated().map { index, value in
                CGPoint(x: CGFloat(index), y: CGFloat(value))
            }
            
            let color = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
            renderer.setData(points, color: color)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateUIView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        // Update data
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index), y: CGFloat(value))
        }
        
        let color = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
        renderer.setData(points, color: color)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay()
    }
    
    class Coordinator {
        var renderer: MetalLineChartRenderer?
    }
}

struct MetalAreaChartViewRepresentable: UIViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        // Set up renderer
        if let renderer = MetalAreaChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            // Convert data to points
            let points = data.enumerated().map { index, value in
                CGPoint(x: CGFloat(index), y: CGFloat(value))
            }
            
            // Use first two colors for gradient (top and bottom)
            let topColor = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 0.3)
            let bottomColor = colors?.count ?? 0 > 1 ? colors![1] : SIMD4<Float>(0.2, 0.6, 1.0, 0.05)
            
            renderer.setData(points, topColor: topColor, bottomColor: bottomColor)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateUIView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        // Update data
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index), y: CGFloat(value))
        }
        
        let topColor = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 0.3)
        let bottomColor = colors?.count ?? 0 > 1 ? colors![1] : SIMD4<Float>(0.2, 0.6, 1.0, 0.05)
        
        renderer.setData(points, topColor: topColor, bottomColor: bottomColor)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay()
    }
    
    class Coordinator {
        var renderer: MetalAreaChartRenderer?
    }
}

#elseif canImport(AppKit)

struct MetalBarChartViewRepresentable: NSViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        // Set up renderer
        if let renderer = MetalBarChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            renderer.setData(data, colors: colors)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateNSView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        renderer.setData(data, colors: colors)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay(mtkView.bounds)
    }
    
    class Coordinator {
        var renderer: MetalBarChartRenderer?
    }
}

struct MetalLineChartViewRepresentable: NSViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        if let renderer = MetalLineChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            let points = data.enumerated().map { index, value in
                CGPoint(x: CGFloat(index), y: CGFloat(value))
            }
            
            let color = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
            renderer.setData(points, color: color)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateNSView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index), y: CGFloat(value))
        }
        
        let color = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
        renderer.setData(points, color: color)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay(mtkView.bounds)
    }
    
    class Coordinator {
        var renderer: MetalLineChartRenderer?
    }
}

struct MetalAreaChartViewRepresentable: NSViewRepresentable {
    let data: [Double]
    let colors: [SIMD4<Float>]?
    let animationProgress: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
        mtkView.framebufferOnly = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        
        if let renderer = MetalAreaChartRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
            
            let points = data.enumerated().map { index, value in
                CGPoint(x: CGFloat(index), y: CGFloat(value))
            }
            
            let topColor = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 0.3)
            let bottomColor = colors?.count ?? 0 > 1 ? colors![1] : SIMD4<Float>(0.2, 0.6, 1.0, 0.05)
            
            renderer.setData(points, topColor: topColor, bottomColor: bottomColor)
            renderer.animationProgress = animationProgress
        }
        
        return mtkView
    }
    
    func updateNSView(_ mtkView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index), y: CGFloat(value))
        }
        
        let topColor = colors?.first ?? SIMD4<Float>(0.2, 0.6, 1.0, 0.3)
        let bottomColor = colors?.count ?? 0 > 1 ? colors![1] : SIMD4<Float>(0.2, 0.6, 1.0, 0.05)
        
        renderer.setData(points, topColor: topColor, bottomColor: bottomColor)
        renderer.animationProgress = animationProgress
        
        mtkView.setNeedsDisplay(mtkView.bounds)
    }
    
    class Coordinator {
        var renderer: MetalAreaChartRenderer?
    }
}

#endif

// MARK: - Color Conversion Helpers

extension SIMD4<Float> {
    init(color: Color) {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(Float(r), Float(g), Float(b), Float(a))
        #elseif canImport(AppKit)
        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            self.init(1, 1, 1, 1)
            return
        }
        self.init(
            Float(rgbColor.redComponent),
            Float(rgbColor.greenComponent),
            Float(rgbColor.blueComponent),
            Float(rgbColor.alphaComponent)
        )
        #endif
    }
}

