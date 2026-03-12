import XCTest
import SwiftUI
@testable import DesignKit

final class NavigationTests: XCTestCase {
    
    // MARK: - DKNavigationBar Tests
    
    func testNavigationBarCreation() {
        let navBar = DKNavigationBar(title: "Test Title")
        XCTAssertNotNil(navBar)
    }
    
    func testNavigationBarWithBackButton() {
        var backTapped = false
        let navBar = DKNavigationBar(title: "Test", onBack: {
            backTapped = true
        })
        XCTAssertNotNil(navBar)
    }
    
    // MARK: - DKTabBar Tests
    
    func testTabBarItemCreation() {
        let item = TabBarItem(
            id: "home",
            icon: "house",
            label: "Home"
        )
        XCTAssertEqual(item.id, "home")
        XCTAssertEqual(item.icon, "house")
        XCTAssertEqual(item.label, "Home")
        XCTAssertNil(item.badge)
    }
    
    func testTabBarItemWithBadge() {
        let item = TabBarItem(
            id: "notifications",
            icon: "bell",
            label: "Notifications",
            badge: "5"
        )
        XCTAssertEqual(item.badge, "5")
    }
    
    func testTabBarItemEquality() {
        let item1 = TabBarItem(id: "home", icon: "house", label: "Home")
        let item2 = TabBarItem(id: "home", icon: "house.fill", label: "Home")
        let item3 = TabBarItem(id: "profile", icon: "person", label: "Profile")
        
        XCTAssertEqual(item1, item2) // Same ID
        XCTAssertNotEqual(item1, item3) // Different ID
    }
    
    func testTabBarCreation() {
        let items = [
            TabBarItem(id: "home", icon: "house", label: "Home"),
            TabBarItem(id: "search", icon: "magnifyingglass", label: "Search")
        ]
        let selectedId = Binding<String>(get: { "home" }, set: { _ in })
        let tabBar = DKTabBar(items: items, selectedId: selectedId)
        
        XCTAssertNotNil(tabBar)
    }
    
    // MARK: - DKSidebar Tests
    
    func testSidebarItemCreation() {
        let item = SidebarItem(
            id: "home",
            icon: "house",
            label: "Home"
        )
        XCTAssertEqual(item.id, "home")
        XCTAssertEqual(item.icon, "house")
        XCTAssertEqual(item.label, "Home")
        XCTAssertNil(item.children)
    }
    
    func testSidebarItemWithChildren() {
        let parent = SidebarItem(
            id: "settings",
            icon: "gear",
            label: "Settings",
            children: [
                SidebarItem(id: "general", label: "General"),
                SidebarItem(id: "privacy", label: "Privacy")
            ]
        )
        
        XCTAssertEqual(parent.children?.count, 2)
        XCTAssertEqual(parent.children?.first?.id, "general")
    }
    
    func testSidebarCreation() {
        let items = [
            SidebarItem(id: "home", icon: "house", label: "Home"),
            SidebarItem(id: "profile", icon: "person", label: "Profile")
        ]
        let selectedId = Binding<String>(get: { "home" }, set: { _ in })
        let sidebar = DKSidebar(items: items, selectedId: selectedId)
        
        XCTAssertNotNil(sidebar)
    }
}


