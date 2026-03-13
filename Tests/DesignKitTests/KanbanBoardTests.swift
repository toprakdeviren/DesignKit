import XCTest
import SwiftUI
@testable import DesignKit

final class KanbanBoardTests: XCTestCase {
    
    struct MockTask: Identifiable {
        let id: Int
    }

    func test_item_initialization_and_equality() {
        let item1 = DKKanbanItem(data: MockTask(id: 1))
        let item2 = DKKanbanItem(data: MockTask(id: 1))
        let item3 = DKKanbanItem(data: MockTask(id: 2))
        
        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
        XCTAssertEqual(item1.id, "1")
    }

    func test_column_initialization() {
        let item = DKKanbanItem(data: MockTask(id: 99))
        let column = DKKanbanColumn(id: "test", title: "Test Col", items: [item])
        
        XCTAssertEqual(column.id, "test")
        XCTAssertEqual(column.title, "Test Col")
        XCTAssertEqual(column.items.count, 1)
        XCTAssertEqual(column.items.first?.id, "99")
    }
}
