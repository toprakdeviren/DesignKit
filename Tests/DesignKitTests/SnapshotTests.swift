import XCTest
import SwiftUI
import SnapshotTesting
@testable import DesignKit

/// Snapshot tests for core DesignKit components
/// Bu testler bileşenlerin görsel regresyon tespiti için kullanılır
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class SnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Snapshot testleri sadece recording modunda veya CI'da çalışsın
        // isRecording = true // İlk çalıştırmada snapshot'ları oluşturmak için
    }
    
    // MARK: - Button Snapshots
    
    func testButtonVariants() {
        let view = VStack(spacing: 16) {
            DKButton("Primary", variant: .primary) {}
            DKButton("Secondary", variant: .secondary) {}
            DKButton("Link", variant: .link) {}
            DKButton("Destructive", variant: .destructive) {}
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testButtonSizes() {
        let view = VStack(spacing: 16) {
            DKButton("Small", variant: .primary, size: .sm) {}
            DKButton("Medium", variant: .primary, size: .md) {}
            DKButton("Large", variant: .primary, size: .lg) {}
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testButtonStates() {
        let view = VStack(spacing: 16) {
            DKButton("Normal", variant: .primary) {}
            DKButton("Loading", variant: .primary, isLoading: true) {}
            DKButton("Disabled", variant: .primary) {}
                .disabled(true)
            DKButton("Full Width", variant: .primary, fullWidth: true) {}
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Card Snapshots
    
    func testCard() {
        let view = VStack(spacing: 16) {
            DKCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .textStyle(.headline)
                    Text("Card body with some content that spans multiple lines.")
                        .textStyle(.body)
                }
            }
            
            DKCardWithHeader {
                Text("Header Content")
                    .textStyle(.headline)
            } content: {
                Text("Card body content")
                    .textStyle(.body)
            }
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Badge Snapshots
    
    func testBadgeVariants() {
        let view = HStack(spacing: 8) {
            DKBadge("Primary", variant: .primary)
            DKBadge("Secondary", variant: .secondary)
            DKBadge("Success", variant: .success)
            DKBadge("Warning", variant: .warning)
            DKBadge("Danger", variant: .danger)
        }
        .padding()
        .frame(width: 600)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testBadgeSizes() {
        let view = HStack(spacing: 8) {
            DKBadge("SM", variant: .primary, size: .sm)
            DKBadge("MD", variant: .primary, size: .md)
            DKBadge("LG", variant: .primary, size: .lg)
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Avatar Snapshots
    
    func testAvatar() {
        let view = HStack(spacing: 16) {
            DKAvatar(image: nil, initials: "AB", size: 40)
            DKAvatar(image: nil, initials: "CD", size: 48)
            DKAvatar(image: nil, initials: "EF", size: 56)
            DKAvatar(image: nil, initials: "GH", size: 64)
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testAvatarGroup() {
        let view = DKAvatarGroup(
            avatars: [
                .init(initials: "AB", status: .online),
                .init(initials: "CD", status: .busy),
                .init(initials: "EF", status: .away),
                .init(initials: "GH", status: .offline),
                .init(initials: "IJ")
            ],
            size: .md,
            maxVisible: 3
        )
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Chip Snapshots
    
    func testChipVariants() {
        let view = VStack(spacing: 8) {
            HStack(spacing: 8) {
                DKChip("Default", variant: .default)
                DKChip("Primary", variant: .primary)
                DKChip("Success", variant: .success)
            }
            HStack(spacing: 8) {
                DKChip("Warning", variant: .warning)
                DKChip("Danger", variant: .danger)
                DKChip("Outlined", variant: .outlined)
            }
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testChipWithIcon() {
        let view = HStack(spacing: 8) {
            DKChip("Swift", icon: "swift", variant: .primary)
            DKChip("iOS", icon: "apple.logo", variant: .default)
            DKChip("Close", icon: "xmark", variant: .danger, size: .sm, onRemove: {})
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Form Components Snapshots
    
    func testTextField() {
        let view = VStack(spacing: 16) {
            DKTextField(
                label: "Email",
                placeholder: "email@example.com",
                text: .constant("")
            )
            
            DKTextField(
                label: "With Error",
                placeholder: "Enter value",
                text: .constant("invalid"),
                validationState: .error,
                errorMessage: "This field is required"
            )
            
            DKTextField(
                label: "Success",
                placeholder: "Enter value",
                text: .constant("valid@email.com"),
                validationState: .success
            )
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testCheckbox() {
        let view = VStack(alignment: .leading, spacing: 12) {
            DKCheckbox(label: "Unchecked", isChecked: .constant(false))
            DKCheckbox(label: "Checked", isChecked: .constant(true))
            DKCheckbox(label: "Disabled", isChecked: .constant(false))
                .disabled(true)
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testRadio() {
        let view = VStack(alignment: .leading, spacing: 12) {
            DKRadio(label: "Option A", value: "a", selectedValue: .constant("a"))
            DKRadio(label: "Option B", value: "b", selectedValue: .constant("a"))
            DKRadio(label: "Option C", value: "c", selectedValue: .constant("a"))
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testSwitch() {
        let view = VStack(alignment: .leading, spacing: 12) {
            DKSwitch(label: "Enabled", isOn: .constant(true))
            DKSwitch(label: "Disabled", isOn: .constant(false))
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Progress Snapshots
    
    func testProgressBar() {
        let view = VStack(spacing: 16) {
            DKProgressBar(value: 0.25, variant: .primary)
            DKProgressBar(value: 0.50, variant: .success)
            DKProgressBar(value: 0.75, variant: .warning)
            DKProgressBar(value: 1.0, variant: .danger)
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testSpinner() {
        let view = HStack(spacing: 24) {
            DKSpinner(size: .sm)
            DKSpinner(size: .md)
            DKSpinner(size: .lg)
        }
        .padding()
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Rating Snapshot
    
    func testRating() {
        let view = VStack(spacing: 16) {
            DKRating(label: "5 Stars", value: .constant(5), max: 5)
            DKRating(label: "3.5 Stars", value: .constant(3.5), max: 5)
            DKRating(label: "Read Only", value: .constant(4), max: 5, isInteractive: false)
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Navigation Snapshots
    
    func testSegmentedBar() {
        let view = VStack(spacing: 16) {
            DKSegmentedBar(
                items: ["Home", "Explore", "Profile"],
                selected: .constant("Home")
            )
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testTabBar() {
        let view = DKTabBar(
            items: [
                TabBarItem(id: "home", icon: "house", label: "Home"),
                TabBarItem(id: "search", icon: "magnifyingglass", label: "Search"),
                TabBarItem(id: "profile", icon: "person", label: "Profile")
            ],
            selectedId: .constant("home")
        )
        .frame(width: 400, height: 80)
        
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 400, height: 80)))
    }
    
    // MARK: - Skeleton Snapshots
    
    func testSkeleton() {
        let view = VStack(spacing: 16) {
            DKSkeletonGroup(layout: .text)
            DKSkeletonGroup(layout: .card)
            DKSkeletonGroup(layout: .avatar)
            DKSkeletonGroup(layout: .listItem)
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    // MARK: - Dark Mode Snapshots
    
    func testButtonDarkMode() {
        let view = VStack(spacing: 16) {
            DKButton("Primary", variant: .primary) {}
            DKButton("Secondary", variant: .secondary) {}
            DKButton("Link", variant: .link) {}
            DKButton("Destructive", variant: .destructive) {}
        }
        .padding()
        .frame(width: 300)
        .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
    
    func testCardDarkMode() {
        let view = DKCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dark Mode Card")
                    .textStyle(.headline)
                Text("Content in dark mode")
                    .textStyle(.body)
            }
        }
        .padding()
        .frame(width: 300)
        .preferredColorScheme(.dark)
        
        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
}

