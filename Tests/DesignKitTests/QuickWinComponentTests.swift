import XCTest
import SwiftUI
@testable import DesignKit

final class QuickWinComponentTests: XCTestCase {
    
    // MARK: - DKChip Tests
    
    func testChipCreation() {
        let chip = DKChip("Swift")
        XCTAssertNotNil(chip)
    }
    
    func testChipWithIcon() {
        let chip = DKChip("iOS", icon: "apple.logo")
        XCTAssertNotNil(chip)
    }
    
    func testChipWithRemove() {
        var removed = false
        let chip = DKChip("Tag", onRemove: {
            removed = true
        })
        XCTAssertNotNil(chip)
    }
    
    func testChipSizes() {
        XCTAssertEqual(ChipSize.sm.fontSize, 12)
        XCTAssertEqual(ChipSize.md.fontSize, 14)
        XCTAssertEqual(ChipSize.lg.fontSize, 16)
        
        XCTAssertEqual(ChipSize.sm.height, 24)
        XCTAssertEqual(ChipSize.md.height, 32)
        XCTAssertEqual(ChipSize.lg.height, 40)
    }
    
    func testChipGroup() {
        let items = ["Swift", "iOS", "macOS"]
        let selectedItems = Binding<Set<String>>(get: { [] }, set: { _ in })
        let chipGroup = DKChipGroup(items: items, selectedItems: selectedItems)
        
        XCTAssertNotNil(chipGroup)
    }
    
    // MARK: - DKSearchBar Tests
    
    func testSearchBarCreation() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let searchBar = DKSearchBar(text: text)
        XCTAssertNotNil(searchBar)
    }
    
    func testSearchBarWithCallback() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        var searchTerm = ""
        
        let searchBar = DKSearchBar(text: text, onSearch: { query in
            searchTerm = query
        })
        
        XCTAssertNotNil(searchBar)
    }
    
    func testSearchBarDebounce() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let searchBar = DKSearchBar(
            text: text,
            debounceInterval: 0.5
        )
        XCTAssertNotNil(searchBar)
    }
    
    // MARK: - DKSkeleton Tests
    
    func testSkeletonCreation() {
        let skeleton = DKSkeleton(width: 200, height: 20)
        XCTAssertNotNil(skeleton)
    }
    
    func testSkeletonShapes() {
        let rectangle = DKSkeleton(height: 20, shape: .rectangle)
        let circle = DKSkeleton(width: 40, height: 40, shape: .circle)
        let rounded = DKSkeleton(height: 20, shape: .roundedRectangle(radius: 8))
        
        XCTAssertNotNil(rectangle)
        XCTAssertNotNil(circle)
        XCTAssertNotNil(rounded)
    }
    
    func testSkeletonGroup() {
        let textSkeleton = DKSkeletonGroup(layout: .text(lines: 3))
        let cardSkeleton = DKSkeletonGroup(layout: .card)
        let avatarSkeleton = DKSkeletonGroup(layout: .avatar)
        let listSkeleton = DKSkeletonGroup(layout: .listItem)
        
        XCTAssertNotNil(textSkeleton)
        XCTAssertNotNil(cardSkeleton)
        XCTAssertNotNil(avatarSkeleton)
        XCTAssertNotNil(listSkeleton)
    }
    
    // MARK: - DKTooltip Tests
    
    func testTooltipCreation() {
        let tooltip = DKTooltip("Yardım metni") {
            Text("Content")
        }
        XCTAssertNotNil(tooltip)
    }
    
    func testTooltipPositions() {
        let topTooltip = DKTooltip("Top", position: .top) { Text("") }
        let bottomTooltip = DKTooltip("Bottom", position: .bottom) { Text("") }
        let leadingTooltip = DKTooltip("Leading", position: .leading) { Text("") }
        let trailingTooltip = DKTooltip("Trailing", position: .trailing) { Text("") }
        
        XCTAssertNotNil(topTooltip)
        XCTAssertNotNil(bottomTooltip)
        XCTAssertNotNil(leadingTooltip)
        XCTAssertNotNil(trailingTooltip)
    }
    
    // MARK: - DKRating Tests
    
    func testRatingCreation() {
        let value = Binding<Int>(get: { 3 }, set: { _ in })
        let rating = DKRating(value: value)
        XCTAssertNotNil(rating)
    }
    
    func testRatingMaxValue() {
        let value = Binding<Int>(get: { 4 }, set: { _ in })
        let rating = DKRating(value: value, max: 10)
        XCTAssertNotNil(rating)
    }
    
    func testRatingReadOnly() {
        let rating = DKRating(value: 4, max: 5)
        XCTAssertNotNil(rating)
    }
    
    func testRatingWithCallback() {
        let value = Binding<Int>(get: { 3 }, set: { _ in })
        var changedValue = 0
        
        let rating = DKRating(value: value, onChange: { newValue in
            changedValue = newValue
        })
        
        XCTAssertNotNil(rating)
    }
}


