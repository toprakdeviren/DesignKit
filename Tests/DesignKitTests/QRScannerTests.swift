import XCTest
import SwiftUI
@testable import DesignKit

final class QRScannerTests: XCTestCase {

    func test_initialization() {
        var resultFound = false
        var errorFound = false
        
        let scanner = DKQRScanner(
            onResult: { _ in resultFound = true },
            onError: { _ in errorFound = true }
        )
        
        // Assert callbacks exist
        scanner.onResult("123")
        XCTAssertTrue(resultFound)
        
        scanner.onError?(NSError(domain: "test", code: -1))
        XCTAssertTrue(errorFound)
    }
}
