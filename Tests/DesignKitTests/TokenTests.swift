import XCTest
@testable import DesignKit

final class TokenTests: XCTestCase {
    
    // MARK: - Spacing Tests
    
    func testSpacingValues() {
        XCTAssertEqual(DesignTokens.Spacing.xs.rawValue, 4)
        XCTAssertEqual(DesignTokens.Spacing.sm.rawValue, 8)
        XCTAssertEqual(DesignTokens.Spacing.md.rawValue, 16)
        XCTAssertEqual(DesignTokens.Spacing.lg.rawValue, 24)
        XCTAssertEqual(DesignTokens.Spacing.xl.rawValue, 32)
    }
    
    // MARK: - Radius Tests
    
    func testRadiusValues() {
        XCTAssertEqual(DesignTokens.Radius.none.rawValue, 0)
        XCTAssertEqual(DesignTokens.Radius.sm.rawValue, 4)
        XCTAssertEqual(DesignTokens.Radius.md.rawValue, 8)
        XCTAssertEqual(DesignTokens.Radius.lg.rawValue, 12)
        XCTAssertEqual(DesignTokens.Radius.xl.rawValue, 16)
        XCTAssertEqual(DesignTokens.Radius.full.rawValue, 9999)
    }
    
    // MARK: - Shadow Tests
    
    func testShadowProperties() {
        let shadow = DesignTokens.Shadow.md
        XCTAssertEqual(shadow.radius, 4)
        XCTAssertEqual(shadow.offset.height, 2)
        XCTAssertEqual(shadow.opacity, 0.15)
    }
    
    func testNoShadow() {
        let shadow = DesignTokens.Shadow.none
        XCTAssertEqual(shadow.radius, 0)
        XCTAssertEqual(shadow.opacity, 0)
    }
    
    // MARK: - Opacity Tests
    
    func testOpacityValues() {
        XCTAssertEqual(DesignTokens.Opacity.transparent.rawValue, 0.0)
        XCTAssertEqual(DesignTokens.Opacity.medium.rawValue, 0.5)
        XCTAssertEqual(DesignTokens.Opacity.opaque.rawValue, 1.0)
    }
    
    // MARK: - Border Width Tests
    
    func testBorderWidthValues() {
        XCTAssertEqual(DesignTokens.BorderWidth.none.rawValue, 0)
        XCTAssertEqual(DesignTokens.BorderWidth.thin.rawValue, 1)
        XCTAssertEqual(DesignTokens.BorderWidth.regular.rawValue, 2)
        XCTAssertEqual(DesignTokens.BorderWidth.thick.rawValue, 4)
    }
}

