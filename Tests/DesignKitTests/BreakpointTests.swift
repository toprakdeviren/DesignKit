import XCTest
@testable import DesignKit

final class BreakpointTests: XCTestCase {
    
    // MARK: - Breakpoint Detection Tests
    
    func testSmallBreakpoint() {
        #if os(iOS)
        let breakpoint = Breakpoint.current(
            horizontalSizeClass: .compact,
            width: 400
        )
        XCTAssertEqual(breakpoint, .sm)
        #endif
    }
    
    func testMediumBreakpoint() {
        let breakpoint = Breakpoint.current(
            horizontalSizeClass: .regular,
            width: 700
        )
        XCTAssertEqual(breakpoint, .md)
    }
    
    func testLargeBreakpoint() {
        let breakpoint = Breakpoint.current(
            horizontalSizeClass: .regular,
            width: 900
        )
        XCTAssertEqual(breakpoint, .lg)
    }
    
    func testExtraLargeBreakpoint() {
        let breakpoint = Breakpoint.current(
            horizontalSizeClass: .regular,
            width: 1100
        )
        XCTAssertEqual(breakpoint, .xl)
    }
    
    func testXXLBreakpoint() {
        let breakpoint = Breakpoint.current(
            horizontalSizeClass: .regular,
            width: 1400
        )
        XCTAssertEqual(breakpoint, .xxl)
    }
    
    // MARK: - Legacy Alias Tests
    
    func testLegacyAliases() {
        XCTAssertEqual(Breakpoint.compact, .sm)
        XCTAssertEqual(Breakpoint.regular, .md)
        XCTAssertEqual(Breakpoint.large, .xl)
    }
    
    // MARK: - Max Container Width Tests
    
    func testMaxContainerWidths() {
        XCTAssertNil(Breakpoint.xs.maxContainerWidth)
        XCTAssertEqual(Breakpoint.sm.maxContainerWidth, 640)
        XCTAssertEqual(Breakpoint.md.maxContainerWidth, 768)
        XCTAssertEqual(Breakpoint.lg.maxContainerWidth, 1024)
        XCTAssertEqual(Breakpoint.xl.maxContainerWidth, 1280)
        XCTAssertEqual(Breakpoint.xxl.maxContainerWidth, 1536)
    }
    
    // MARK: - Min Width Tests
    
    func testMinWidths() {
        XCTAssertEqual(Breakpoint.xs.minWidth, 0)
        XCTAssertEqual(Breakpoint.sm.minWidth, 375)
        XCTAssertEqual(Breakpoint.md.minWidth, 640)
        XCTAssertEqual(Breakpoint.lg.minWidth, 768)
        XCTAssertEqual(Breakpoint.xl.minWidth, 1024)
        XCTAssertEqual(Breakpoint.xxl.minWidth, 1280)
    }
    
    // MARK: - Comparable Tests
    
    func testBreakpointComparison() {
        XCTAssertLessThan(Breakpoint.xs, Breakpoint.sm)
        XCTAssertLessThan(Breakpoint.sm, Breakpoint.md)
        XCTAssertLessThan(Breakpoint.md, Breakpoint.lg)
        XCTAssertLessThan(Breakpoint.lg, Breakpoint.xl)
        XCTAssertLessThan(Breakpoint.xl, Breakpoint.xxl)
    }
}

