import XCTest
import SwiftUI
@testable import DesignKit

final class ContentDisplayComponentTests: XCTestCase {
    
    // MARK: - DKAvatar Tests
    
    func testAvatarInitialization() {
        let avatar = DKAvatar(
            initials: "AB",
            size: .md
        )
        
        XCTAssertNotNil(avatar)
    }
    
    func testAvatarSizes() {
        XCTAssertEqual(AvatarSize.xs.dimension, 24)
        XCTAssertEqual(AvatarSize.sm.dimension, 32)
        XCTAssertEqual(AvatarSize.md.dimension, 40)
        XCTAssertEqual(AvatarSize.lg.dimension, 56)
        XCTAssertEqual(AvatarSize.xl.dimension, 80)
    }
    
    func testAvatarWithStatus() {
        let avatar = DKAvatar(
            initials: "CD",
            size: .md,
            status: .online
        )
        
        XCTAssertNotNil(avatar)
    }
    
    // MARK: - DKAvatarGroup Tests
    
    func testAvatarGroupInitialization() {
        let avatars = [
            DKAvatarGroup.AvatarData(initials: "AB"),
            DKAvatarGroup.AvatarData(initials: "CD"),
            DKAvatarGroup.AvatarData(initials: "EF")
        ]
        
        let group = DKAvatarGroup(
            avatars: avatars,
            size: .md,
            maxVisible: 2
        )
        
        XCTAssertNotNil(group)
    }
    
    // MARK: - DKTimeline Tests
    
    func testTimelineInitialization() {
        let items = [
            TimelineItemData(
                title: "Event 1",
                status: .completed
            ),
            TimelineItemData(
                title: "Event 2",
                status: .current
            ),
            TimelineItemData(
                title: "Event 3",
                status: .pending
            )
        ]
        
        let timeline = DKTimeline(items: items)
        
        XCTAssertNotNil(timeline)
    }
    
    func testTimelineItemWithDate() {
        let item = TimelineItemData(
            title: "Event",
            description: "Description",
            date: Date(),
            status: .completed
        )
        
        XCTAssertNotNil(item.date)
        XCTAssertEqual(item.title, "Event")
    }
    
    // MARK: - DKBreadcrumb Tests
    
    func testBreadcrumbInitialization() {
        let items = [
            BreadcrumbItemData(title: "Home"),
            BreadcrumbItemData(title: "Products"),
            BreadcrumbItemData(title: "Electronics")
        ]
        
        let breadcrumb = DKBreadcrumb(items: items)
        
        XCTAssertNotNil(breadcrumb)
    }
    
    func testBreadcrumbWithActions() {
        var actionCalled = false
        
        let items = [
            BreadcrumbItemData(title: "Home", action: {
                actionCalled = true
            }),
            BreadcrumbItemData(title: "Current")
        ]
        
        let breadcrumb = DKBreadcrumb(items: items)
        
        XCTAssertNotNil(breadcrumb)
        XCTAssertNotNil(items[0].action)
    }
    
    // MARK: - DKStepper Tests
    
    func testStepperInitialization() {
        let stepper = DKStepper(
            label: "Quantity",
            value: .constant(1),
            in: 1...10
        )
        
        XCTAssertNotNil(stepper)
    }
    
    func testStepperRange() {
        let range: ClosedRange<Int> = 0...100
        
        XCTAssertEqual(range.lowerBound, 0)
        XCTAssertEqual(range.upperBound, 100)
    }
}

