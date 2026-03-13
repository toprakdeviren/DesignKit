import XCTest
import SwiftUI
@testable import DesignKit

final class CodeBlockTests: XCTestCase {

    func test_initialization_with_language() {
        let code = "print(\"Hello\")"
        let block = DKCodeBlock(code: code, language: "swift")
        
        XCTAssertEqual(block.code, code)
        XCTAssertEqual(block.language, "swift")
    }

    func test_initialization_without_language() {
        let code = "print(\"Hello\")"
        let block = DKCodeBlock(code: code)
        
        XCTAssertEqual(block.code, code)
        XCTAssertNil(block.language)
    }
    
    func test_empty_code() {
        let block = DKCodeBlock(code: "")
        XCTAssertEqual(block.code, "")
    }

    func test_multiline_code() {
        let code = """
        func test() {
            return 1
        }
        """
        let block = DKCodeBlock(code: code, language: "swift")
        XCTAssertEqual(block.code.split(separator: "\n").count, 3)
    }
}
