import XCTest
@testable import DesignKit

final class TypographyTests: XCTestCase {
    
    // MARK: - Text Style Tests
    
    func testTextStyleSizes() {
        XCTAssertEqual(TypographyTokens.TextStyle.display.size, 48)
        XCTAssertEqual(TypographyTokens.TextStyle.title1.size, 34)
        XCTAssertEqual(TypographyTokens.TextStyle.headline.size, 17)
        XCTAssertEqual(TypographyTokens.TextStyle.body.size, 17)
        XCTAssertEqual(TypographyTokens.TextStyle.caption1.size, 12)
    }
    
    func testTextStyleWeights() {
        XCTAssertEqual(TypographyTokens.TextStyle.display.weight, .bold)
        XCTAssertEqual(TypographyTokens.TextStyle.headline.weight, .semibold)
        XCTAssertEqual(TypographyTokens.TextStyle.body.weight, .regular)
    }
    
    func testTextStyleLineHeights() {
        XCTAssertEqual(TypographyTokens.TextStyle.display.lineHeight, 56)
        XCTAssertEqual(TypographyTokens.TextStyle.body.lineHeight, 22)
        XCTAssertEqual(TypographyTokens.TextStyle.caption2.lineHeight, 13)
    }
}

