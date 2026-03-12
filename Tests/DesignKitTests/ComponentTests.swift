import XCTest
import SwiftUI
@testable import DesignKit

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class ComponentTests: XCTestCase {
    
    // MARK: - Button Tests
    
    func testButtonVariants() {
        let variants: [ButtonVariant] = [.primary, .secondary, .link, .destructive]
        
        for variant in variants {
            let button = DKButton("Test", variant: variant) {}
            XCTAssertNotNil(button)
        }
    }
    
    func testButtonSizes() {
        let sizes: [ButtonSize] = [.sm, .md, .lg]
        
        for size in sizes {
            XCTAssertGreaterThan(size.fontSize, 0)
            XCTAssertGreaterThan(size.verticalPadding, 0)
            XCTAssertGreaterThan(size.horizontalPadding, 0)
        }
    }
    
    func testButtonStates() {
        // Test disabled state
        let disabledButton = DKButton("Disabled", isDisabled: true) {}
        XCTAssertNotNil(disabledButton)
        
        // Test loading state
        let loadingButton = DKButton("Loading", isLoading: true) {}
        XCTAssertNotNil(loadingButton)
        
        // Test normal state
        let normalButton = DKButton("Normal") {}
        XCTAssertNotNil(normalButton)
    }
    
    // MARK: - Badge Tests
    
    func testBadgeVariants() {
        let variants: [BadgeVariant] = [.primary, .secondary, .success, .warning, .danger]
        
        for variant in variants {
            let badge = DKBadge("Test", variant: variant)
            XCTAssertNotNil(badge)
        }
    }
    
    func testCustomBadgeVariant() {
        let customVariant = BadgeVariant.custom(background: .red, foreground: .white)
        let badge = DKBadge("Custom", variant: customVariant)
        XCTAssertNotNil(badge)
    }
    
    // MARK: - Card Tests
    
    func testCardCreation() {
        let card = DKCard {
            Text("Card Content")
        }
        XCTAssertNotNil(card)
    }
    
    func testCardWithCustomParameters() {
        let card = DKCard(
            padding: .lg,
            cornerRadius: .xl,
            shadow: .md
        ) {
            Text("Custom Card")
        }
        XCTAssertNotNil(card)
    }
    
    // MARK: - Grid Tests
    
    func testGridCreation() {
        let grid = Grid {
            Row {
                Col(span: 6) { Text("Half") }
                Col(span: 6) { Text("Half") }
            }
        }
        XCTAssertNotNil(grid)
    }
    
    func testResponsiveColumns() {
        let col = Col(compact: 12, regular: 6, large: 4) {
            Text("Responsive")
        }
        XCTAssertNotNil(col)
    }
    
    func testColSpan() {
        let span = ColSpan(compact: 12, regular: 6, large: 4)
        XCTAssertEqual(span.compact, 12)
        XCTAssertEqual(span.regular, 6)
        XCTAssertEqual(span.large, 4)
    }
    
    func testColSpanForBreakpoint() {
        let span = ColSpan(compact: 12, regular: 6, large: 4)
        XCTAssertEqual(span.span(for: .compact), 12)
        XCTAssertEqual(span.span(for: .regular), 6)
        XCTAssertEqual(span.span(for: .large), 4)
    }
}

