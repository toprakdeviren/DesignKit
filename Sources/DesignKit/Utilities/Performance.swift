import SwiftUI

// MARK: - View Caching

/// Cache expensive view calculations
@propertyWrapper
public struct ViewCache<Value> {
    private var value: Value?
    private let calculator: () -> Value
    
    public init(calculator: @escaping () -> Value) {
        self.calculator = calculator
    }
    
    public var wrappedValue: Value {
        mutating get {
            if let value = value {
                return value
            }
            let newValue = calculator()
            value = newValue
            return newValue
        }
    }
}

// MARK: - Lazy Loading

/// Lazy load views when they become visible
public struct LazyView<Content: View>: View {
    private let build: () -> Content
    
    public init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }
    
    public var body: some View {
        build()
    }
}

/// Lazy load views with threshold
public struct DeferredView<Content: View>: View {
    @State private var isLoaded = false
    private let content: () -> Content
    private let delay: TimeInterval
    
    public init(delay: TimeInterval = 0, @ViewBuilder content: @escaping () -> Content) {
        self.delay = delay
        self.content = content
    }
    
    public var body: some View {
        Group {
            if isLoaded {
                content()
            } else {
                Color.clear
                    .onAppear {
                        if delay > 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                isLoaded = true
                            }
                        } else {
                            isLoaded = true
                        }
                    }
            }
        }
    }
}

// MARK: - View Modifiers

extension View {
    /// Lazy load this view
    public func lazyLoad() -> some View {
        LazyView { self }
    }
    
    /// Defer loading with delay
    public func deferred(delay: TimeInterval = 0) -> some View {
        DeferredView(delay: delay) { self }
    }
    
    /// Optimize rendering with drawingGroup for complex views
    public func optimized() -> some View {
        self.drawingGroup()
    }
}

// MARK: - List Performance

// Note: .equatable() is already provided by SwiftUI for Equatable views
// No custom implementation needed here

// MARK: - Memory Management

/// Weak reference wrapper for avoiding retain cycles
@propertyWrapper
public struct Weak<T: AnyObject> {
    private weak var value: T?
    
    public init(wrappedValue: T?) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: T? {
        get { value }
        set { value = newValue }
    }
}


