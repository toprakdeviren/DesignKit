import XCTest
@testable import DesignKit

final class ThemeTests: XCTestCase {
    
    // MARK: - Theme Initialization Tests
    
    func testDefaultTheme() {
        let theme = Theme.default
        XCTAssertNotNil(theme.colorTokens)
        XCTAssertNotNil(theme.designTokens)
        XCTAssertNotNil(theme.typographyTokens)
    }
    
    // MARK: - Custom Theme Tests
    
    func testCustomThemeInitialization() {
        let customTheme = Theme(
            colorTokens: DefaultColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
        XCTAssertNotNil(customTheme)
    }
}

