import XCTest
import SwiftUI
@testable import DesignKit

final class PerformanceTests: XCTestCase {
    
    // MARK: - View Caching Tests
    
    func testViewCacheCreation() {
        var cache = ViewCache {
            return "expensive calculation"
        }
        
        let value1 = cache.wrappedValue
        let value2 = cache.wrappedValue
        
        XCTAssertEqual(value1, value2)
        XCTAssertEqual(value1, "expensive calculation")
    }
    
    // MARK: - Lazy Loading Tests
    
    func testLazyViewCreation() {
        let lazyView = LazyView {
            Text("Lazy loaded")
        }
        XCTAssertNotNil(lazyView)
    }
    
    func testDeferredViewCreation() {
        let deferredView = DeferredView(delay: 0.1) {
            Text("Deferred content")
        }
        XCTAssertNotNil(deferredView)
    }
    
    // MARK: - Memory Management Tests
    
    func testWeakReferenceWrapper() {
        class TestObject {
            let value = "test"
        }
        
        var object: TestObject? = TestObject()
        let weak = Weak(wrappedValue: object)
        
        XCTAssertNotNil(weak.wrappedValue)
        XCTAssertEqual(weak.wrappedValue?.value, "test")
        
        object = nil
        XCTAssertNil(weak.wrappedValue)
    }
}


