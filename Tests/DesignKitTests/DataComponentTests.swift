import XCTest
import SwiftUI
@testable import DesignKit

final class DataComponentTests: XCTestCase {
    
    // MARK: - Test Data
    
    struct TestItem: Identifiable {
        let id: UUID
        let name: String
        let value: String
    }
    
    // MARK: - DKTable Tests
    
    func testTableInitialization() {
        let data = [
            TestItem(id: UUID(), name: "Item 1", value: "Value 1"),
            TestItem(id: UUID(), name: "Item 2", value: "Value 2")
        ]
        
        let columns = [
            TableColumn<TestItem>(title: "Name") { item in
                AnyView(Text(item.name))
            },
            TableColumn<TestItem>(title: "Value") { item in
                AnyView(Text(item.value))
            }
        ]
        
        let table = DKTable(
            columns: columns,
            data: data
        )
        
        XCTAssertNotNil(table)
    }
    
    func testTableWithStripedRows() {
        let data = [
            TestItem(id: UUID(), name: "Item 1", value: "Value 1")
        ]
        
        let columns = [
            TableColumn<TestItem>(title: "Name") { item in
                AnyView(Text(item.name))
            }
        ]
        
        let table = DKTable(
            columns: columns,
            data: data,
            isStriped: true
        )
        
        XCTAssertNotNil(table)
    }
    
    func testTableColumnWidth() {
        let column = TableColumn<TestItem>(
            title: "Fixed Width",
            width: 150
        ) { item in
            AnyView(Text(item.name))
        }
        
        XCTAssertEqual(column.width, 150)
    }
    
    // MARK: - DKAccordion Tests
    
    func testAccordionInitialization() {
        let items = [
            AccordionItemData(
                title: "Section 1",
                content: AnyView(Text("Content 1"))
            ),
            AccordionItemData(
                title: "Section 2",
                content: AnyView(Text("Content 2"))
            )
        ]
        
        let accordion = DKAccordion(items: items)
        
        XCTAssertNotNil(accordion)
    }
    
    func testAccordionWithInitiallyExpanded() {
        let items = [
            AccordionItemData(
                title: "Expanded",
                content: AnyView(Text("Content")),
                isInitiallyExpanded: true
            )
        ]
        
        let accordion = DKAccordion(items: items)
        
        XCTAssertNotNil(accordion)
        XCTAssertTrue(items[0].isInitiallyExpanded)
    }
    
    func testAccordionMultipleExpanded() {
        let items = [
            AccordionItemData(
                title: "Section 1",
                content: AnyView(Text("Content 1"))
            ),
            AccordionItemData(
                title: "Section 2",
                content: AnyView(Text("Content 2"))
            )
        ]
        
        let accordion = DKAccordion(
            items: items,
            allowMultipleExpanded: true
        )
        
        XCTAssertNotNil(accordion)
    }
    
    func testAccordionWithIcon() {
        let item = AccordionItemData(
            title: "Section",
            content: AnyView(Text("Content")),
            icon: "star.fill"
        )
        
        XCTAssertEqual(item.icon, "star.fill")
    }
}

