import Metal
import MetalKit
import simd

// MARK: - Gradient Vertex Data

struct GradientVertex {
    var position: SIMD2<Float>
    var gradientPosition: Float  // 0.0 = top, 1.0 = bottom
    
    init(position: SIMD2<Float>, gradientPosition: Float) {
        self.position = position
        self.gradientPosition = gradientPosition
    }
}

// MARK: - Metal Area Chart Renderer

public final class MetalAreaChartRenderer: NSObject {
    
    // MARK: - Properties
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var areaPipelineState: MTLRenderPipelineState?
    private var linePipelineState: MTLRenderPipelineState?
    
    private var areaVertexBuffer: MTLBuffer?
    private var lineVertexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?
    
    private var areaVertices: [GradientVertex] = []
    private var lineVertices: [LineVertex] = []
    private var viewportSize: SIMD2<Float> = .zero
    
    // Gradient colors
    public var topColor: SIMD4<Float> = SIMD4<Float>(0.2, 0.6, 1.0, 0.3)
    public var bottomColor: SIMD4<Float> = SIMD4<Float>(0.2, 0.6, 1.0, 0.05)
    public var lineColor: SIMD4<Float> = SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
    public var lineThickness: Float = 2.0
    
    // Animation
    public var animationProgress: Float = 1.0 {
        didSet {
            updateVertices()
        }
    }
    
    // Chart data
    private var dataPoints: [CGPoint] = []
    
    // MARK: - Initialization
    
    public init?(device: MTLDevice) {
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = queue
        
        super.init()
        
        setupPipelines()
    }
    
    // MARK: - Setup
    
    private func setupPipelines() {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            print("❌ Failed to load Metal library")
            return
        }
        
        // Area (gradient fill) pipeline
        if let vertexFunction = library.makeFunction(name: "gradientVertexShader"),
           let fragmentFunction = library.makeFunction(name: "gradientFragmentShader") {
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            // Enable blending for gradient
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            do {
                areaPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("❌ Failed to build area pipeline state: \(error)")
            }
        }
        
        // Line pipeline (reuse line shader)
        if let vertexFunction = library.makeFunction(name: "lineVertexShader"),
           let fragmentFunction = library.makeFunction(name: "lineFragmentShader") {
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            do {
                linePipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("❌ Failed to build line pipeline state: \(error)")
            }
        }
    }
    
    // MARK: - Data Management
    
    public func setData(_ points: [CGPoint], topColor: SIMD4<Float>? = nil, bottomColor: SIMD4<Float>? = nil) {
        dataPoints = points
        
        if let topColor = topColor {
            self.topColor = topColor
        }
        if let bottomColor = bottomColor {
            self.bottomColor = bottomColor
        }
        
        updateVertices()
    }
    
    private func updateVertices() {
        guard !dataPoints.isEmpty, viewportSize.y > 0 else { return }
        
        // Apply animation progress (trim)
        let visibleCount = max(2, Int(Float(dataPoints.count) * animationProgress))
        let visiblePoints = Array(dataPoints.prefix(visibleCount))
        
        guard visiblePoints.count >= 2 else { return }
        
        // Build area fill vertices (triangle strip from top to bottom)
        areaVertices.removeAll()
        
        for (_, point) in visiblePoints.enumerated() {
            let x = Float(point.x)
            let y = Float(point.y)
            let bottomY = viewportSize.y
            
            // Calculate gradient position (0.0 at data point, 1.0 at bottom)
            let gradientPos = (y - 0) / viewportSize.y
            
            // Top vertex (data point)
            areaVertices.append(GradientVertex(
                position: SIMD2<Float>(x, y),
                gradientPosition: gradientPos
            ))
            
            // Bottom vertex (baseline)
            areaVertices.append(GradientVertex(
                position: SIMD2<Float>(x, bottomY),
                gradientPosition: 1.0
            ))
        }
        
        // Build line vertices
        lineVertices = visiblePoints.map { point in
            LineVertex(
                position: SIMD2<Float>(Float(point.x), Float(point.y)),
                color: lineColor,
                thickness: lineThickness
            )
        }
        
        // Update buffers
        if !areaVertices.isEmpty {
            let areaBufferSize = areaVertices.count * MemoryLayout<GradientVertex>.stride
            areaVertexBuffer = device.makeBuffer(
                bytes: areaVertices,
                length: areaBufferSize,
                options: [.storageModeShared]
            )
        }
        
        if !lineVertices.isEmpty {
            let lineBufferSize = lineVertices.count * MemoryLayout<LineVertex>.stride
            lineVertexBuffer = device.makeBuffer(
                bytes: lineVertices,
                length: lineBufferSize,
                options: [.storageModeShared]
            )
        }
    }
    
    public func setViewportSize(_ size: CGSize) {
        viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
        
        var uniforms = Uniforms(viewportSize: viewportSize)
        uniformBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            options: [.storageModeShared]
        )
        
        updateVertices()
    }
    
    // MARK: - Rendering
    
    public func render(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        // Draw area fill first
        if let areaPipelineState = areaPipelineState,
           let areaVertexBuffer = areaVertexBuffer,
           let uniformBuffer = uniformBuffer,
           !areaVertices.isEmpty {
            
            renderEncoder.setRenderPipelineState(areaPipelineState)
            renderEncoder.setVertexBuffer(areaVertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            
            // Pass gradient colors to fragment shader
            var topColorValue = topColor
            var bottomColorValue = bottomColor
            renderEncoder.setFragmentBytes(&topColorValue, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
            renderEncoder.setFragmentBytes(&bottomColorValue, length: MemoryLayout<SIMD4<Float>>.stride, index: 1)
            
            // Draw as triangle strip
            renderEncoder.drawPrimitives(
                type: .triangleStrip,
                vertexStart: 0,
                vertexCount: areaVertices.count
            )
        }
        
        // Draw line on top
        if let linePipelineState = linePipelineState,
           let lineVertexBuffer = lineVertexBuffer,
           let uniformBuffer = uniformBuffer,
           !lineVertices.isEmpty {
            
            renderEncoder.setRenderPipelineState(linePipelineState)
            renderEncoder.setVertexBuffer(lineVertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            
            // Draw line strip
            renderEncoder.drawPrimitives(
                type: .lineStrip,
                vertexStart: 0,
                vertexCount: lineVertices.count
            )
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - MTKViewDelegate

extension MetalAreaChartRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setViewportSize(size)
    }
    
    public func draw(in view: MTKView) {
        render(in: view)
    }
}

