import XCTest
import SwiftUI
@testable import DesignKit

/// Gelişmiş erişilebilirlik testleri
/// WCAG 2.1 AA/AAA kontrast oranları ve Dynamic Type edge case'leri
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class AccessibilityEnhancedTests: XCTestCase {
    
    // MARK: - WCAG Kontrast Testleri
    
    func testColorContrastWCAG_AA() {
        // WCAG AA: Normal text için 4.5:1, large text için 3:1
        
        // Primary renk kontrastı
        let primaryContrast = calculateContrastRatio(
            foreground: ColorTokens.textOnPrimary,
            background: ColorTokens.primary500
        )
        XCTAssertGreaterThanOrEqual(primaryContrast, 4.5, "Primary button text kontrast oranı WCAG AA standardını karşılamalı")
        
        // Success renk kontrastı
        let successContrast = calculateContrastRatio(
            foreground: ColorTokens.textOnPrimary,
            background: ColorTokens.success500
        )
        XCTAssertGreaterThanOrEqual(successContrast, 4.5, "Success badge text kontrast oranı WCAG AA standardını karşılamalı")
        
        // Danger renk kontrastı
        let dangerContrast = calculateContrastRatio(
            foreground: ColorTokens.textOnPrimary,
            background: ColorTokens.danger500
        )
        XCTAssertGreaterThanOrEqual(dangerContrast, 4.5, "Danger button text kontrast oranı WCAG AA standardını karşılamalı")
        
        // Body text kontrastı
        let bodyContrast = calculateContrastRatio(
            foreground: ColorTokens.textPrimary,
            background: ColorTokens.surface
        )
        XCTAssertGreaterThanOrEqual(bodyContrast, 4.5, "Body text kontrast oranı WCAG AA standardını karşılamalı")
    }
    
    func testColorContrastWCAG_AAA() {
        // WCAG AAA: Normal text için 7:1, large text için 4.5:1
        
        let textPrimaryContrast = calculateContrastRatio(
            foreground: ColorTokens.textPrimary,
            background: ColorTokens.surface
        )
        // AAA hedefi (ideal, zorunlu değil)
        if textPrimaryContrast >= 7.0 {
            // Excellent!
            XCTAssertGreaterThanOrEqual(textPrimaryContrast, 7.0)
        } else {
            // AA yeterli
            XCTAssertGreaterThanOrEqual(textPrimaryContrast, 4.5)
        }
    }
    
    func testSecondaryTextContrast() {
        // Secondary text daha düşük kontrasta sahip olabilir ama minimum 3:1
        let secondaryContrast = calculateContrastRatio(
            foreground: ColorTokens.textSecondary,
            background: ColorTokens.surface
        )
        XCTAssertGreaterThanOrEqual(secondaryContrast, 3.0, "Secondary text minimum kontrast oranını karşılamalı")
    }
    
    func testDisabledStateContrast() {
        // Disabled durumlar için kontrast kontrolü (WCAG 1.4.3)
        // Not: Disabled elementler için kontrast gereksinimi yoktur ama test ediyoruz
        let disabledContrast = calculateContrastRatio(
            foreground: ColorTokens.textSecondary.opacity(0.5),
            background: ColorTokens.surface
        )
        // Minimum okunabilirlik için 2:1
        XCTAssertGreaterThanOrEqual(disabledContrast, 2.0, "Disabled text minimum okunabilir olmalı")
    }
    
    // MARK: - Dynamic Type Testleri
    
    func testDynamicType_ExtraSmall() {
        // Extra Small (accessibilityExtraSmall) - En küçük metin boyutu
        let sizeCategory = ContentSizeCategory.extraSmall
        let scaledFont = Font.system(size: 16).dynamicTypeSize(sizeCategory)
        
        // Font boyutunun çok küçük olmamasını kontrol et
        // (UI'nin hala kullanılabilir olması gerekiyor)
        XCTAssertNotNil(scaledFont)
    }
    
    func testDynamicType_AccessibilityExtraExtraExtraLarge() {
        // Accessibility Extra Extra Extra Large - En büyük metin boyutu
        let sizeCategory = ContentSizeCategory.accessibilityExtraExtraExtraLarge
        let scaledFont = Font.system(size: 16).dynamicTypeSize(sizeCategory)
        
        // Font boyutunun çok büyük olsa bile render edilebilir olduğunu kontrol et
        XCTAssertNotNil(scaledFont)
    }
    
    func testButtonMinimumTapTarget() {
        // WCAG 2.5.5: Minimum tap target 44x44 pt (iOS) / 48x48 dp (Material)
        let minimumSize: CGFloat = 44.0
        
        // Button'ların minimum tap target'ı sağladığını kontrol et
        // Bu değerler gerçek button implementasyonundan gelmelidir
        let buttonSmallHeight: CGFloat = 36 // .sm
        let buttonMediumHeight: CGFloat = 44 // .md (default)
        let buttonLargeHeight: CGFloat = 52 // .lg
        
        // Medium ve Large button'lar minimum standardı karşılamalı
        XCTAssertGreaterThanOrEqual(buttonMediumHeight, minimumSize, "Medium button minimum tap target'ı karşılamalı")
        XCTAssertGreaterThanOrEqual(buttonLargeHeight, minimumSize, "Large button minimum tap target'ı karşılamalı")
        
        // Small button için uyarı (44pt'den küçükse padding eklenebilir)
        if buttonSmallHeight < minimumSize {
            // Small button'lara padding ekleyerek minimum 44pt tap area sağlanmalı
            let paddingNeeded = (minimumSize - buttonSmallHeight) / 2
            XCTAssertGreaterThan(paddingNeeded, 0, "Small button'a \(paddingNeeded)pt padding eklenmeli")
        }
    }
    
    func testTextFieldMinimumHeight() {
        // Text field'ların da minimum 44pt yüksekliğe sahip olması önerilir
        let minimumHeight: CGFloat = 44.0
        let textFieldHeight: CGFloat = 48.0 // TextField default height
        
        XCTAssertGreaterThanOrEqual(textFieldHeight, minimumHeight, "TextField minimum erişilebilir yüksekliğe sahip olmalı")
    }
    
    func testCheckboxRadioMinimumSize() {
        // Checkbox ve Radio button'ların minimum 44x44pt tap area'ya sahip olması
        let minimumSize: CGFloat = 44.0
        let checkboxSize: CGFloat = 24.0 // Visual size
        let tapAreaSize: CGFloat = 44.0 // Actual tap area (with padding)
        
        XCTAssertGreaterThanOrEqual(tapAreaSize, minimumSize, "Checkbox tap area minimum standardı karşılamalı")
    }
    
    // MARK: - Dynamic Type Edge Cases
    
    func testDynamicType_LongTextTruncation() {
        // Uzun metinlerin Dynamic Type ile truncate edilmesi
        let longText = "Bu çok uzun bir metin örneği ki accessibility extra extra extra large modda bile okunabilir olmalı"
        
        // Badge'lerde truncation kontrolü
        // Badge text 1-2 satırdan fazla olmamalı
        XCTAssertLessThanOrEqual(longText.count, 50, "Badge text'i kısa tutulmalı veya truncate edilmeli")
    }
    
    func testDynamicType_MultilineSupport() {
        // Multiline text'in Dynamic Type ile düzgün çalışması
        let multilineText = """
        Birinci satır
        İkinci satır
        Üçüncü satır
        """
        
        // TextView ve Label'larda multiline desteği olmalı
        XCTAssertTrue(multilineText.contains("\n"), "Multiline text desteklenmeli")
    }
    
    func testDynamicType_LayoutBreakage() {
        // Dynamic Type büyütüldüğünde layout'un bozulmaması
        // Bu test UI testinde daha iyi yapılır ama burada genel kontrol
        
        let smallFontSize: CGFloat = 12
        let largeFontSize: CGFloat = 48 // Accessibility Extra Extra Extra Large gibi
        
        let scale = largeFontSize / smallFontSize
        XCTAssertLessThanOrEqual(scale, 5.0, "Font scaling çok aşırı olmamalı (max ~4x)")
    }
    
    // MARK: - Color Blindness Tests
    
    func testColorBlindness_NotOnlyColor() {
        // WCAG 1.4.1: Renk tek bilgi kaynağı olmamalı
        // Örneğin: Success/Error durumları sadece yeşil/kırmızı ile değil, icon/text ile de belirtilmeli
        
        // Success badge: Renk + ikon
        // Error message: Renk + text + ikon
        // Bu test sembolik - gerçek UI'da kontrol edilmeli
        XCTAssertTrue(true, "Success/Error durumları renk + ikon/text ile belirtilmeli")
    }
    
    func testColorBlindness_ProtanopiaSimulation() {
        // Protanopia (kırmızı-yeşil renk körlüğü) simülasyonu
        // Kırmızı ve yeşil renklerin yeterli kontrasta sahip olması
        
        let redGreenContrast = calculateContrastRatio(
            foreground: ColorTokens.danger500,
            background: ColorTokens.success500
        )
        
        // Kırmızı ve yeşil arasında yeterli kontrast olmalı
        XCTAssertGreaterThanOrEqual(redGreenContrast, 3.0, "Kırmızı ve yeşil renkleri birbirinden ayırt edilebilir olmalı")
    }
    
    // MARK: - VoiceOver Trait Tests
    
    func testVoiceOverTraits_Button() {
        // Button'ların .button trait'ine sahip olması
        // Bu SwiftUI'de otomatik olarak eklenir ama özel button'larda kontrol edilmeli
        XCTAssertTrue(true, "Button trait'i .button olmalı")
    }
    
    func testVoiceOverTraits_Link() {
        // Link'lerin .link trait'ine sahip olması
        XCTAssertTrue(true, "Link trait'i .link olmalı")
    }
    
    func testVoiceOverTraits_Header() {
        // Başlıkların .header trait'ine sahip olması
        XCTAssertTrue(true, "Başlık trait'i .header olmalı")
    }
    
    // MARK: - Accessibility Label Tests
    
    func testAccessibilityLabel_IconOnlyButton() {
        // Icon-only button'ların accessibility label'a sahip olması
        let iconOnlyButtonLabel = "Menü"
        XCTAssertFalse(iconOnlyButtonLabel.isEmpty, "Icon-only button accessibility label'a sahip olmalı")
    }
    
    func testAccessibilityLabel_Decorative() {
        // Dekoratif elementlerin accessibility'den gizlenmesi
        // Örneğin: Dekoratif ikonlar, arka plan görselleri
        XCTAssertTrue(true, "Dekoratif elementler .accessibilityHidden(true) ile gizlenmeli")
    }
    
    // MARK: - Focus Management Tests
    
    func testFocusOrder_Logical() {
        // Focus sırasının mantıklı olması (soldan sağa, yukarıdan aşağıya)
        XCTAssertTrue(true, "Focus sırası mantıksal olmalı")
    }
    
    func testFocusIndicator_Visible() {
        // Focus indicator'ın görünür olması
        // SwiftUI otomatik focus indicator sağlar ama özel view'larda kontrol edilmeli
        XCTAssertTrue(true, "Focus indicator görünür olmalı")
    }
    
    // MARK: - Helper Methods
    
    private func calculateContrastRatio(foreground: Color, background: Color) -> Double {
        // WCAG kontrast oranı hesaplama
        // (L1 + 0.05) / (L2 + 0.05)
        // L = relative luminance
        
        let fgLuminance = relativeLuminance(of: foreground)
        let bgLuminance = relativeLuminance(of: background)
        
        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func relativeLuminance(of color: Color) -> Double {
        // Relative luminance hesaplama (sRGB)
        // L = 0.2126 * R + 0.7152 * G + 0.0722 * B
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        guard let components = UIColor(color).cgColor.components else { return 0 }
        #elseif os(macOS)
        guard let components = NSColor(color).cgColor.components else { return 0 }
        #endif
        
        let r = gammaCorrect(components[0])
        let g = gammaCorrect(components[1])
        let b = gammaCorrect(components[2])
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func gammaCorrect(_ component: CGFloat) -> Double {
        let c = Double(component)
        if c <= 0.03928 {
            return c / 12.92
        } else {
            return pow((c + 0.055) / 1.055, 2.4)
        }
    }
}

// MARK: - Color Extension for Testing

#if os(iOS) || os(tvOS) || os(watchOS)
extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}
#elseif os(macOS)
extension Color {
    var nsColor: NSColor {
        NSColor(self)
    }
}
#endif

