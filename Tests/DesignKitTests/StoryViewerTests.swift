import XCTest
import SwiftUI
@testable import DesignKit

final class StoryViewerTests: XCTestCase {

    struct IdentifiableMock: Identifiable {
        let id: Int
    }

    func test_initialization() {
        let items = [IdentifiableMock(id: 1), IdentifiableMock(id: 2)]
        var didComplete = false
        
        let viewer = DKStoryViewer(
            items: items,
            durationPerItem: 3.0,
            onComplete: { didComplete = true }
        ) { item in
            Text("\\(item.id)")
        }
        
        XCTAssertEqual(viewer.items.count, 2)
        XCTAssertEqual(viewer.durationPerItem, 3.0)
        
        viewer.onComplete()
        XCTAssertTrue(didComplete)
    }

    func test_empty_initialization() {
        let viewer = DKStoryViewer(
            items: [IdentifiableMock](),
            durationPerItem: 5.0,
            onComplete: { }
        ) { _ in
            EmptyView()
        }
        
        XCTAssertTrue(viewer.items.isEmpty)
    }
}
