import Metal
import MetalKit

// MARK: - Advanced Metal Optimizations

/// Advanced Metal rendering optimizations for maximum performance
public final class MetalOptimizations {
    
    // MARK: - Triple Buffering
    
    /// Triple buffering manager for smooth rendering without stalling
    public final class TripleBufferingManager {
        
        private let device: MTLDevice
        private var buffers: [MTLBuffer] = []
        private var currentBufferIndex: Int = 0
        private let bufferCount: Int = 3
        private let semaphore: DispatchSemaphore
        
        public init?(device: MTLDevice, bufferSize: Int) {
            self.device = device
            self.semaphore = DispatchSemaphore(value: bufferCount)
            
            // Set up triple buffers
            for _ in 0..<bufferCount {
                guard let buffer = device.makeBuffer(
                    length: bufferSize,
                    options: [.storageModeShared]
                ) else {
                    return nil
                }
                buffers.append(buffer)
            }
        }
        
        /// Get next available buffer (waits if all buffers are in use)
        public func nextBuffer() -> MTLBuffer {
            semaphore.wait()
            let buffer = buffers[currentBufferIndex]
            currentBufferIndex = (currentBufferIndex + 1) % bufferCount
            return buffer
        }
        
        /// Signal that buffer is no longer in use
        public func bufferCompleted() {
            semaphore.signal()
        }
        
        /// Update all buffers with new data
        public func updateAllBuffers(_ data: UnsafeRawPointer, length: Int) {
            for buffer in buffers {
                memcpy(buffer.contents(), data, length)
            }
        }
    }
    
    // MARK: - Argument Buffers
    
    /// Argument buffer manager for efficient resource binding
    public final class ArgumentBufferManager {
        
        private let device: MTLDevice
        private var argumentBuffer: MTLBuffer?
        private var argumentEncoder: MTLArgumentEncoder?
        
        public init?(device: MTLDevice, function: MTLFunction, bufferIndex: Int = 0) {
            self.device = device
            
            // Set up argument encoder
            let encoder = function.makeArgumentEncoder(bufferIndex: bufferIndex)
            self.argumentEncoder = encoder
            
            // Set up argument buffer
            guard let buffer = device.makeBuffer(
                length: encoder.encodedLength,
                options: [.storageModeShared]
            ) else {
                return nil
            }
            
            self.argumentBuffer = buffer
        }
        
        /// Encode buffers into argument buffer
        public func encodeBuffers(_ buffers: [MTLBuffer]) {
            guard let encoder = argumentEncoder,
                  let argumentBuffer = argumentBuffer else {
                return
            }
            
            encoder.setArgumentBuffer(argumentBuffer, offset: 0)
            
            for (index, buffer) in buffers.enumerated() {
                encoder.setBuffer(buffer, offset: 0, index: index)
            }
        }
        
        /// Encode textures into argument buffer
        public func encodeTextures(_ textures: [MTLTexture]) {
            guard let encoder = argumentEncoder,
                  let argumentBuffer = argumentBuffer else {
                return
            }
            
            encoder.setArgumentBuffer(argumentBuffer, offset: 0)
            
            for (index, texture) in textures.enumerated() {
                encoder.setTexture(texture, index: index)
            }
        }
        
        /// Get the argument buffer
        public var buffer: MTLBuffer? {
            return argumentBuffer
        }
    }
    
    // MARK: - Resource Heap
    
    /// Resource heap manager for efficient memory allocation
    public final class ResourceHeapManager {
        
        private let device: MTLDevice
        private var heap: MTLHeap?
        
        public init?(device: MTLDevice, size: Int) {
            self.device = device
            
            let heapDescriptor = MTLHeapDescriptor()
            heapDescriptor.size = size
            heapDescriptor.storageMode = .private
            heapDescriptor.cpuCacheMode = .defaultCache
            heapDescriptor.hazardTrackingMode = .tracked
            
            guard let heap = device.makeHeap(descriptor: heapDescriptor) else {
                return nil
            }
            
            self.heap = heap
        }
        
        /// Allocate buffer from heap
        public func makeBuffer(length: Int) -> MTLBuffer? {
            return heap?.makeBuffer(length: length, options: [.storageModePrivate])
        }
        
        /// Allocate texture from heap
        public func makeTexture(descriptor: MTLTextureDescriptor) -> MTLTexture? {
            return heap?.makeTexture(descriptor: descriptor)
        }
        
        /// Current heap usage
        public var usedSize: Int {
            return heap?.usedSize ?? 0
        }
        
        public var maxAvailableSize: Int {
            return heap?.maxAvailableSize(alignment: 256) ?? 0
        }
    }
    
    // MARK: - Compute Pipeline Cache
    
    /// Cache for compute pipelines to avoid recompilation
    public final class PipelineCache {
        
        private var cache: [String: MTLComputePipelineState] = [:]
        private let device: MTLDevice
        
        public init(device: MTLDevice) {
            self.device = device
        }
        
        /// Get or build a compute pipeline
        public func getOrBuildPipeline(
            functionName: String,
            library: MTLLibrary
        ) -> MTLComputePipelineState? {
            // Check cache
            if let cached = cache[functionName] {
                return cached
            }
            
            // Build new pipeline
            guard let function = library.makeFunction(name: functionName) else {
                return nil
            }
            
            do {
                let pipeline = try device.makeComputePipelineState(function: function)
                cache[functionName] = pipeline
                return pipeline
            } catch {
                print("❌ Failed to build compute pipeline: \(error)")
                return nil
            }
        }
        
        /// Clear cache
        public func clearCache() {
            cache.removeAll()
        }
    }
    
    // MARK: - Performance Hints
    
    public struct PerformanceHints {
        
        /// Optimal threadgroup size for compute operations
        public static func optimalThreadgroupSize(
            for pipeline: MTLComputePipelineState,
            dataCount: Int
        ) -> MTLSize {
            let maxThreads = pipeline.maxTotalThreadsPerThreadgroup
            let threadExecutionWidth = pipeline.threadExecutionWidth
            
            // Use multiples of threadExecutionWidth for best performance
            let width = min(maxThreads, ((dataCount + threadExecutionWidth - 1) / threadExecutionWidth) * threadExecutionWidth)
            
            return MTLSize(width: width, height: 1, depth: 1)
        }
        
        /// Calculate optimal threadgroups
        public static func calculateThreadgroups(
            dataCount: Int,
            threadgroupSize: MTLSize
        ) -> MTLSize {
            let width = (dataCount + threadgroupSize.width - 1) / threadgroupSize.width
            return MTLSize(width: width, height: 1, depth: 1)
        }
        
        /// Recommended buffer size alignment
        public static let bufferAlignment: Int = 256
        
        /// Align size to optimal boundary
        public static func alignedSize(_ size: Int) -> Int {
            return ((size + bufferAlignment - 1) / bufferAlignment) * bufferAlignment
        }
    }
    
    // MARK: - Memory Pool
    
    /// Reusable buffer pool to avoid frequent allocations
    public final class BufferPool {
        
        private let device: MTLDevice
        private var availableBuffers: [Int: [MTLBuffer]] = [:]
        private var inUseBuffers: Set<ObjectIdentifier> = []
        
        public init(device: MTLDevice) {
            self.device = device
        }
        
        /// Get buffer from pool or allocate new one
        public func getBuffer(size: Int) -> MTLBuffer? {
            let alignedSize = PerformanceHints.alignedSize(size)
            
            // Check for available buffer
            if var buffers = availableBuffers[alignedSize], !buffers.isEmpty {
                let buffer = buffers.removeLast()
                availableBuffers[alignedSize] = buffers
                inUseBuffers.insert(ObjectIdentifier(buffer))
                return buffer
            }
            
            // Allocate new buffer
            guard let buffer = device.makeBuffer(
                length: alignedSize,
                options: [.storageModeShared]
            ) else {
                return nil
            }
            
            inUseBuffers.insert(ObjectIdentifier(buffer))
            return buffer
        }
        
        /// Return buffer to pool
        public func returnBuffer(_ buffer: MTLBuffer) {
            let identifier = ObjectIdentifier(buffer)
            guard inUseBuffers.contains(identifier) else {
                return
            }
            
            inUseBuffers.remove(identifier)
            
            let size = buffer.length
            var buffers = availableBuffers[size] ?? []
            buffers.append(buffer)
            availableBuffers[size] = buffers
        }
        
        /// Clear pool
        public func clear() {
            availableBuffers.removeAll()
            inUseBuffers.removeAll()
        }
        
        /// Pool statistics
        public var statistics: (available: Int, inUse: Int) {
            let available = availableBuffers.values.reduce(0) { $0 + $1.count }
            return (available: available, inUse: inUseBuffers.count)
        }
    }
}

// MARK: - Optimized Renderer Base

/// Base class for optimized Metal renderers
open class OptimizedMetalRenderer {
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    
    // Optimization managers
    public var tripleBuffering: MetalOptimizations.TripleBufferingManager?
    public var bufferPool: MetalOptimizations.BufferPool
    public var pipelineCache: MetalOptimizations.PipelineCache
    
    public init?(device: MTLDevice) {
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            return nil
        }
        
        self.commandQueue = queue
        self.bufferPool = MetalOptimizations.BufferPool(device: device)
        self.pipelineCache = MetalOptimizations.PipelineCache(device: device)
    }
    
    /// Enable triple buffering with specified buffer size
    public func enableTripleBuffering(bufferSize: Int) {
        tripleBuffering = MetalOptimizations.TripleBufferingManager(
            device: device,
            bufferSize: bufferSize
        )
    }
    
    /// Cleanup resources
    public func cleanup() {
        bufferPool.clear()
        pipelineCache.clearCache()
    }
}

