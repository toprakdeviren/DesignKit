import XCTest
import SwiftUI
@testable import DesignKit

/// Performance benchmark testleri
/// Sıcak yollar (hot paths) için performans ölçümleri
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class PerformanceBenchmarkTests: XCTestCase {
    
    // MARK: - Theme Performance
    
    func testPerformance_ThemeAccess() {
        // Tema erişiminin performansı
        // Tema her view render'da erişilir, hızlı olmalı
        
        let theme = Theme.default
        
        measure {
            for _ in 0..<1000 {
                _ = theme.colorTokens.primary500
                _ = theme.designTokens.spacing.md
                _ = theme.typographyTokens.textStyle(.body)
            }
        }
    }
    
    func testPerformance_ThemeSwitch() {
        // Tema değiştirme performansı
        // Runtime tema değiştirme hızlı olmalı
        
        let defaultTheme = Theme.default
        let customTheme = Theme(
            colorTokens: DefaultColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
        
        measure {
            for i in 0..<100 {
                _ = i % 2 == 0 ? defaultTheme : customTheme
            }
        }
    }
    
    func testPerformance_ColorTokenAccess() {
        // Color token erişiminin performansı
        
        measure {
            for _ in 0..<10000 {
                _ = ColorTokens.primary500
                _ = ColorTokens.success500
                _ = ColorTokens.danger500
                _ = ColorTokens.textPrimary
            }
        }
    }
    
    // MARK: - Button Performance
    
    func testPerformance_ButtonCreation() {
        // Button oluşturma performansı
        // Button en sık kullanılan bileşen
        
        measure {
            for _ in 0..<1000 {
                _ = DKButton("Test", variant: .primary) {}
            }
        }
    }
    
    func testPerformance_ButtonRender() {
        // Button render performansı (body hesaplama)
        
        let button = DKButton("Test Button", variant: .primary) {}
        
        measure {
            for _ in 0..<1000 {
                _ = button.body
            }
        }
    }
    
    // MARK: - Card Performance
    
    func testPerformance_CardCreation() {
        // Card oluşturma performansı
        
        measure {
            for _ in 0..<1000 {
                _ = DKCard {
                    Text("Card Content")
                }
            }
        }
    }
    
    // MARK: - Badge Performance
    
    func testPerformance_BadgeCreation() {
        // Badge oluşturma performansı
        // Badge küçük ve hızlı olmalı
        
        measure {
            for _ in 0..<1000 {
                _ = DKBadge("New", variant: .primary)
            }
        }
    }
    
    // MARK: - Grid Layout Performance
    
    func testPerformance_GridCalculation() {
        // Grid column hesaplama performansı
        
        measure {
            for _ in 0..<1000 {
                let totalColumns = 12
                let span = 6
                let spacing: CGFloat = 16
                let containerWidth: CGFloat = 375
                
                _ = (containerWidth - spacing * CGFloat(totalColumns - 1)) / CGFloat(totalColumns) * CGFloat(span)
            }
        }
    }
    
    func testPerformance_GridCreation() {
        // Grid oluşturma performansı
        
        measure {
            for _ in 0..<100 {
                _ = Grid {
                    Row {
                        Col(span: 6) { Text("A") }
                        Col(span: 6) { Text("B") }
                    }
                }
            }
        }
    }
    
    // MARK: - Typography Performance
    
    func testPerformance_TextStyleApplication() {
        // Text style uygulama performansı
        
        let text = Text("Sample Text")
        
        measure {
            for _ in 0..<1000 {
                _ = text.textStyle(.body)
            }
        }
    }
    
    func testPerformance_DynamicTypeScaling() {
        // Dynamic Type scaling performansı
        
        measure {
            for _ in 0..<1000 {
                _ = Font.system(size: 16)
            }
        }
    }
    
    // MARK: - Shadow Performance
    
    func testPerformance_ShadowApplication() {
        // Shadow uygulama performansı
        // Shadow pahalı bir işlem olabilir
        
        let view = Rectangle().fill(Color.white)
        
        measure {
            for _ in 0..<100 {
                _ = view.shadow(.md)
            }
        }
    }
    
    // MARK: - Avatar Performance
    
    func testPerformance_AvatarCreation() {
        // Avatar oluşturma performansı
        
        measure {
            for _ in 0..<500 {
                _ = DKAvatar(image: nil, initials: "AB", size: 48)
            }
        }
    }
    
    func testPerformance_AvatarGroupCreation() {
        // Avatar group oluşturma performansı
        
        let avatars = [
            AvatarData(initials: "AB"),
            AvatarData(initials: "CD"),
            AvatarData(initials: "EF"),
            AvatarData(initials: "GH"),
            AvatarData(initials: "IJ")
        ]
        
        measure {
            for _ in 0..<100 {
                _ = DKAvatarGroup(avatars: avatars, size: .md, maxVisible: 3)
            }
        }
    }
    
    // MARK: - Form Component Performance
    
    func testPerformance_TextFieldCreation() {
        // TextField oluşturma performansı
        
        measure {
            for _ in 0..<500 {
                _ = DKTextField(
                    label: "Email",
                    placeholder: "email@example.com",
                    text: .constant("")
                )
            }
        }
    }
    
    func testPerformance_CheckboxToggle() {
        // Checkbox toggle performansı
        
        var isChecked = false
        
        measure {
            for _ in 0..<10000 {
                isChecked.toggle()
            }
        }
    }
    
    // MARK: - List Rendering Performance
    
    func testPerformance_ListOfButtons() {
        // Button listesi render performansı
        
        measure {
            let buttons = (0..<50).map { i in
                DKButton("Button \(i)", variant: .primary) {}
            }
            _ = buttons.count
        }
    }
    
    func testPerformance_ListOfCards() {
        // Card listesi render performansı
        
        measure {
            let cards = (0..<50).map { i in
                DKCard {
                    Text("Card \(i)")
                }
            }
            _ = cards.count
        }
    }
    
    // MARK: - Memory Performance
    
    func testMemory_ThemeRetention() {
        // Tema memory retention testi
        // Tema singleton olmalı, her view için yeni instance yaratılmamalı
        
        let theme1 = Theme.default
        let theme2 = Theme.default
        
        XCTAssertTrue(theme1.colorTokens.primary500 == theme2.colorTokens.primary500,
                     "Tema token'ları aynı değerleri döndürmeli")
    }
    
    func testMemory_ButtonAllocation() {
        // Button memory allocation testi
        
        measure(metrics: [XCTMemoryMetric()]) {
            autoreleasepool {
                for _ in 0..<1000 {
                    _ = DKButton("Test", variant: .primary) {}
                }
            }
        }
    }
    
    func testMemory_CardAllocation() {
        // Card memory allocation testi
        
        measure(metrics: [XCTMemoryMetric()]) {
            autoreleasepool {
                for _ in 0..<1000 {
                    _ = DKCard {
                        Text("Content")
                    }
                }
            }
        }
    }
    
    // MARK: - Skeleton Animation Performance
    
    func testPerformance_SkeletonAnimation() {
        // Skeleton shimmer animation performansı
        
        measure {
            for _ in 0..<100 {
                _ = DKSkeleton(shape: .rectangle, width: 200, height: 20)
            }
        }
    }
    
    // MARK: - Progress Bar Performance
    
    func testPerformance_ProgressBarUpdate() {
        // ProgressBar güncelleme performansı
        // Animation sırasında sürekli güncellenir
        
        measure {
            for i in 0..<100 {
                let progress = Double(i) / 100.0
                _ = DKProgressBar(value: progress, variant: .primary)
            }
        }
    }
    
    // MARK: - Chip Performance
    
    func testPerformance_ChipCreation() {
        // Chip oluşturma performansı
        
        measure {
            for _ in 0..<1000 {
                _ = DKChip("Tag", variant: .primary)
            }
        }
    }
    
    func testPerformance_ChipGroup() {
        // Chip group performansı (FlowLayout ile)
        
        let items = (0..<20).map { "Tag \($0)" }
        
        measure {
            for _ in 0..<100 {
                _ = DKChipGroup(items: items, selectedItems: .constant([]))
            }
        }
    }
    
    // MARK: - Timeline Performance
    
    func testPerformance_TimelineCreation() {
        // Timeline oluşturma performansı
        
        let items = [
            TimelineItemData(title: "Item 1", status: .completed),
            TimelineItemData(title: "Item 2", status: .current),
            TimelineItemData(title: "Item 3", status: .pending)
        ]
        
        measure {
            for _ in 0..<100 {
                _ = DKTimeline(items: items)
            }
        }
    }
    
    // MARK: - Modal Performance
    
    func testPerformance_ModalPresentation() {
        // Modal presentation performansı
        
        var isPresented = false
        
        measure {
            for _ in 0..<1000 {
                isPresented.toggle()
            }
        }
    }
    
    // MARK: - Breakpoint Performance
    
    func testPerformance_BreakpointDetection() {
        // Breakpoint detection performansı
        
        measure {
            for width in stride(from: 320, through: 1920, by: 10) {
                _ = Breakpoint.detect(width: CGFloat(width))
            }
        }
    }
    
    // MARK: - Color Manipulation Performance
    
    func testPerformance_ColorOpacity() {
        // Color opacity işleminin performansı
        
        let color = ColorTokens.primary500
        
        measure {
            for i in 0..<1000 {
                _ = color.opacity(Double(i % 100) / 100.0)
            }
        }
    }
    
    // MARK: - Utility Modifier Performance
    
    func testPerformance_PaddingModifier() {
        // Padding modifier performansı
        
        let view = Text("Test")
        
        measure {
            for _ in 0..<1000 {
                _ = view.padding(.md)
            }
        }
    }
    
    func testPerformance_BackgroundStyleModifier() {
        // BackgroundStyle modifier performansı
        
        let view = Text("Test")
        
        measure {
            for _ in 0..<1000 {
                _ = view.backgroundStyle(.surface)
            }
        }
    }
    
    // MARK: - Concurrent Performance
    
    func testPerformance_ConcurrentButtonCreation() {
        // Eş zamanlı button oluşturma performansı
        
        measure {
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                for _ in 0..<10 {
                    _ = DKButton("Test", variant: .primary) {}
                }
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testPerformance_EmptyButton() {
        // Boş button performansı
        
        measure {
            for _ in 0..<1000 {
                _ = DKButton("", variant: .primary) {}
            }
        }
    }
    
    func testPerformance_LongTextButton() {
        // Uzun text içeren button performansı
        
        let longText = String(repeating: "Long Text ", count: 50)
        
        measure {
            for _ in 0..<100 {
                _ = DKButton(longText, variant: .primary) {}
            }
        }
    }
    
    // MARK: - Benchmark Assertions
    
    func testBenchmark_ButtonCreationUnder10ms() {
        // Button oluşturma 10ms'den hızlı olmalı (1000 button için)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<1000 {
            _ = DKButton("Test", variant: .primary) {}
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // 1000 button < 10ms => ortalama 10μs per button
        XCTAssertLessThan(timeElapsed, 0.01, "Button oluşturma 10ms'den hızlı olmalı (1000 button için)")
    }
    
    func testBenchmark_ThemeAccessUnder1ms() {
        // Tema erişimi 1ms'den hızlı olmalı (10000 erişim için)
        
        let theme = Theme.default
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<10000 {
            _ = theme.colorTokens.primary500
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // 10000 erişim < 1ms => ortalama 0.1μs per access
        XCTAssertLessThan(timeElapsed, 0.001, "Tema erişimi 1ms'den hızlı olmalı (10000 erişim için)")
    }
}

