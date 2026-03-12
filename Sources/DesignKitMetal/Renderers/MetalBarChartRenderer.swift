import Metal
import MetalKit
import simd

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Bar Instance Data

struct BarInstance {
    var position: SIMD2<Float>    // x, y base position
    var size: SIMD2<Float>         // width, height
    var color: SIMD4<Float>        // RGBA
    var animationProgress: Float   // 0.0 to 1.0
    
    init(position: SIMD2<Float>, size: SIMD2<Float>, color: SIMD4<Float>, animationProgress: Float) {
        self.position = position
        self.size = size
        self.color = color
        self.animationProgress = animationProgress
    }
}

// MARK: - Uniforms

struct Uniforms {
    var projectionMatrix: simd_float4x4
    var viewportSize: SIMD2<Float>
    var time: Float
    var cornerRadius: Float
    
    init(viewportSize: SIMD2<Float>, time: Float = 0, cornerRadius: Float = 4.0) {
        self.projectionMatrix = matrix_identity_float4x4
        self.viewportSize = viewportSize
        self.time = time
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Metal Bar Chart Renderer

public final class MetalBarChartRenderer: NSObject {
    
    // MARK: - Properties
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var instanceBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?
    
    private var instances: [BarInstance] = []
    private var currentAnimationProgress: Float = 0.0
    
    public var animationProgress: Float {
        get { currentAnimationProgress }
        set {
            currentAnimationProgress = newValue
            updateInstances()
        }
    }
    
    // Chart data
    private var dataPoints: [(value: Double, color: SIMD4<Float>)] = []
    private var viewportSize: SIMD2<Float> = .zero
    private var maxValue: Double = 1.0
    
    // MARK: - Initialization
    
    public init?(device: MTLDevice) {
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = queue
        
        super.init()
        
        setupPipeline()
    }
    
    // MARK: - Setup
    
    private func setupPipeline() {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            print("❌ Failed to load Metal library")
            return
        }
        
        guard let vertexFunction = library.makeFunction(name: "barVertexShader"),
              let fragmentFunction = library.makeFunction(name: "barFragmentShader") else {
            print("❌ Failed to load shader functions")
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Enable blending for transparency
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("❌ Failed to build pipeline state: \(error)")
        }
    }
    
    // MARK: - Data Management
    
    public func setData(_ values: [Double], colors: [SIMD4<Float>]?) {
        guard !values.isEmpty else { return }
        
        maxValue = values.max() ?? 1.0
        
        dataPoints = values.enumerated().map { index, value in
            let color = colors?[safe: index] ?? SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
            return (value: value, color: color)
        }
        
        updateInstances()
    }
    
    private func updateInstances() {
        guard !dataPoints.isEmpty, viewportSize.x > 0, viewportSize.y > 0 else { return }
        
        let count = dataPoints.count
        let spacing: Float = 8.0
        let totalSpacing = spacing * Float(count - 1)
        let barWidth = (viewportSize.x - totalSpacing) / Float(count)
        
        // Leave space for labels (40pt at bottom)
        let chartHeight = viewportSize.y - 40.0
        
        instances = dataPoints.enumerated().map { index, point in
            let x = Float(index) * (barWidth + spacing)
            let normalizedValue = Float(point.value / maxValue)
            let barHeight = chartHeight * normalizedValue
            
            return BarInstance(
                position: SIMD2<Float>(x, viewportSize.y - barHeight),
                size: SIMD2<Float>(barWidth, barHeight),
                color: point.color,
                animationProgress: currentAnimationProgress
            )
        }
        
        // Update buffer
        if !instances.isEmpty {
            let bufferSize = instances.count * MemoryLayout<BarInstance>.stride
            instanceBuffer = device.makeBuffer(
                bytes: instances,
                length: bufferSize,
                options: [.storageModeShared]
            )
        }
    }
    
    public func setViewportSize(_ size: CGSize) {
        viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
        updateInstances()
        
        // Update uniform buffer
        var uniforms = Uniforms(viewportSize: viewportSize)
        uniformBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            options: [.storageModeShared]
        )
    }
    
    // MARK: - Rendering
    
    public func render(in view: MTKView) {
        guard let pipelineState = pipelineState,
              let drawable = view.currentDrawable,
              let instanceBuffer = instanceBuffer,
              let uniformBuffer = uniformBuffer,
              !instances.isEmpty else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        // Draw instanced quads (4 vertices per quad, using triangle strip)
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4,
            instanceCount: instances.count
        )
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - MTKViewDelegate

extension MetalBarChartRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setViewportSize(size)
    }
    
    public func draw(in view: MTKView) {
        render(in: view)
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

