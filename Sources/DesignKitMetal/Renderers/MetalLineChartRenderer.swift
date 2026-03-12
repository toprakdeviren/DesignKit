import Metal
import MetalKit
import simd

// MARK: - Line Vertex Data

struct LineVertex {
    var position: SIMD2<Float>
    var color: SIMD4<Float>
    var thickness: Float
    
    init(position: SIMD2<Float>, color: SIMD4<Float>, thickness: Float = 3.0) {
        self.position = position
        self.color = color
        self.thickness = thickness
    }
}

// MARK: - Point2D for Compute Shader

struct Point2D {
    var position: SIMD2<Float>
    
    init(position: SIMD2<Float>) {
        self.position = position
    }
}

// MARK: - Metal Line Chart Renderer

public final class MetalLineChartRenderer: NSObject {
    
    // MARK: - Properties
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var computePipelineState: MTLComputePipelineState?
    
    private var vertexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?
    private var inputPointsBuffer: MTLBuffer?
    private var outputPointsBuffer: MTLBuffer?
    
    private var vertices: [LineVertex] = []
    private var viewportSize: SIMD2<Float> = .zero
    private var lineColor: SIMD4<Float> = SIMD4<Float>(0.2, 0.6, 1.0, 1.0)
    private var lineThickness: Float = 3.0
    
    // Animation
    public var animationProgress: Float = 1.0 {
        didSet {
            updateVertices()
        }
    }
    
    // Smoothing
    public var enableSmoothing: Bool = true  // Enable by default
    public var smoothingTension: Float = 0.5
    public var useGPUSmoothing: Bool = true  // Use compute shader when available
    
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
        
        setupPipeline()
        setupComputePipeline()
    }
    
    // MARK: - Setup
    
    private func setupPipeline() {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            print("❌ Failed to load Metal library")
            return
        }
        
        guard let vertexFunction = library.makeFunction(name: "lineVertexShader"),
              let fragmentFunction = library.makeFunction(name: "lineFragmentShader") else {
            print("❌ Failed to load line shader functions")
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Enable blending
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
            print("❌ Failed to build line pipeline state: \(error)")
        }
    }
    
    private func setupComputePipeline() {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            return
        }
        
        guard let computeFunction = library.makeFunction(name: "smoothLinePoints") else {
            print("❌ Failed to load compute function")
            return
        }
        
        do {
            computePipelineState = try device.makeComputePipelineState(function: computeFunction)
        } catch {
            print("❌ Failed to build compute pipeline state: \(error)")
        }
    }
    
    // MARK: - Data Management
    
    public func setData(_ points: [CGPoint], color: SIMD4<Float>? = nil) {
        dataPoints = points
        if let color = color {
            lineColor = color
        }
        updateVertices()
    }
    
    private func updateVertices() {
        guard !dataPoints.isEmpty else { return }
        
        var points = dataPoints
        
        // Apply smoothing if enabled
        if enableSmoothing && dataPoints.count > 3 {
            if useGPUSmoothing && computePipelineState != nil {
                // GPU smoothing via compute shader
                points = applySmoothingGPU(to: dataPoints)
            } else {
                // CPU fallback
                points = applySmoothingCPU(to: dataPoints)
            }
        }
        
        // Apply animation progress (trim line)
        let visibleCount = Int(Float(points.count) * animationProgress)
        let visiblePoints = Array(points.prefix(visibleCount))
        
        vertices = visiblePoints.map { point in
            LineVertex(
                position: SIMD2<Float>(Float(point.x), Float(point.y)),
                color: lineColor,
                thickness: lineThickness
            )
        }
        
        if !vertices.isEmpty {
            let bufferSize = vertices.count * MemoryLayout<LineVertex>.stride
            vertexBuffer = device.makeBuffer(
                bytes: vertices,
                length: bufferSize,
                options: [.storageModeShared]
            )
        }
    }
    
    // GPU-based Catmull-Rom smoothing using compute shader
    private func applySmoothingGPU(to points: [CGPoint]) -> [CGPoint] {
        guard points.count > 3,
              let computePipeline = computePipelineState else {
            return applySmoothingCPU(to: points)
        }
        
        // Convert to Point2D
        var inputPoints = points.map { Point2D(position: SIMD2<Float>(Float($0.x), Float($0.y))) }
        
        // Set up buffers
        let inputBufferSize = inputPoints.count * MemoryLayout<Point2D>.stride
        guard let inputBuffer = device.makeBuffer(
            bytes: &inputPoints,
            length: inputBufferSize,
            options: [.storageModeShared]
        ) else {
            return applySmoothingCPU(to: points)
        }
        
        // Output buffer (same size)
        guard let outputBuffer = device.makeBuffer(
            length: inputBufferSize,
            options: [.storageModeShared]
        ) else {
            return applySmoothingCPU(to: points)
        }
        
        // Set up command buffer and encoder
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return applySmoothingCPU(to: points)
        }
        
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
        
        var pointCount = UInt32(points.count)
        var tension = smoothingTension
        computeEncoder.setBytes(&pointCount, length: MemoryLayout<UInt32>.stride, index: 2)
        computeEncoder.setBytes(&tension, length: MemoryLayout<Float>.stride, index: 3)
        
        // Dispatch threads
        let threadGroupSize = MTLSize(width: min(computePipeline.maxTotalThreadsPerThreadgroup, points.count), height: 1, depth: 1)
        let threadGroups = MTLSize(
            width: (points.count + threadGroupSize.width - 1) / threadGroupSize.width,
            height: 1,
            depth: 1
        )
        
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Read back results
        let outputPointer = outputBuffer.contents().bindMemory(to: Point2D.self, capacity: points.count)
        let outputArray = Array(UnsafeBufferPointer(start: outputPointer, count: points.count))
        
        return outputArray.map { CGPoint(x: CGFloat($0.position.x), y: CGFloat($0.position.y)) }
    }
    
    // CPU-side Catmull-Rom smoothing (fallback)
    private func applySmoothingCPU(to points: [CGPoint]) -> [CGPoint] {
        guard points.count > 3 else { return points }
        
        var smoothed: [CGPoint] = [points[0]]
        
        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i < points.count - 2 ? points[i + 2] : points[i + 1]
            
            // Add interpolated points
            for step in 0...4 {
                let t = Float(step) / 4.0
                let t2 = t * t
                let t3 = t2 * t
                
                let x = 0.5 * (
                    (2.0 * Float(p1.x)) +
                    (-Float(p0.x) + Float(p2.x)) * t +
                    (2.0 * Float(p0.x) - 5.0 * Float(p1.x) + 4.0 * Float(p2.x) - Float(p3.x)) * t2 +
                    (-Float(p0.x) + 3.0 * Float(p1.x) - 3.0 * Float(p2.x) + Float(p3.x)) * t3
                )
                
                let y = 0.5 * (
                    (2.0 * Float(p1.y)) +
                    (-Float(p0.y) + Float(p2.y)) * t +
                    (2.0 * Float(p0.y) - 5.0 * Float(p1.y) + 4.0 * Float(p2.y) - Float(p3.y)) * t2 +
                    (-Float(p0.y) + 3.0 * Float(p1.y) - 3.0 * Float(p2.y) + Float(p3.y)) * t3
                )
                
                smoothed.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        
        smoothed.append(points.last!)
        return smoothed
    }
    
    public func setViewportSize(_ size: CGSize) {
        viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
        
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
              let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer,
              !vertices.isEmpty else {
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
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Draw line strip
        renderEncoder.drawPrimitives(
            type: .line,
            vertexStart: 0,
            vertexCount: vertices.count
        )
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - MTKViewDelegate

extension MetalLineChartRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setViewportSize(size)
    }
    
    public func draw(in view: MTKView) {
        render(in: view)
    }
}

