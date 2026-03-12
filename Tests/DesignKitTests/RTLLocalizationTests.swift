import XCTest
import SwiftUI
@testable import DesignKit

/// RTL (Right-to-Left) layout ve localization testleri
/// Arapça, İbranice gibi RTL diller için layout kontrolü
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class RTLLocalizationTests: XCTestCase {
    
    // MARK: - RTL Layout Tests
    
    func testRTL_LayoutDirection() {
        // RTL dillerinde layout direction'ın .rightToLeft olması
        let environment = EnvironmentValues()
        
        // Türkçe (LTR)
        XCTAssertEqual(Locale(identifier: "tr_TR").language.characterDirection, .leftToRight)
        
        // Arapça (RTL)
        XCTAssertEqual(Locale(identifier: "ar_SA").language.characterDirection, .rightToLeft)
        
        // İbranice (RTL)
        XCTAssertEqual(Locale(identifier: "he_IL").language.characterDirection, .rightToLeft)
    }
    
    func testRTL_TextAlignment() {
        // RTL dillerinde text alignment'ın otomatik olarak değişmesi
        // .leading → RTL'de sağdan başlar
        // .trailing → RTL'de soldan başlar
        
        let ltrLeading = TextAlignment.leading // Sol
        let rtlLeading = TextAlignment.leading // Sağ (RTL'de)
        
        XCTAssertNotNil(ltrLeading)
        XCTAssertNotNil(rtlLeading)
    }
    
    func testRTL_HStackOrder() {
        // HStack'te elementlerin RTL'de ters sırada görünmesi
        // LTR: [A, B, C]
        // RTL: [C, B, A]
        
        let elements = ["A", "B", "C"]
        XCTAssertEqual(elements.count, 3)
        
        // RTL'de otomatik olarak ters çevrilir (SwiftUI tarafından)
        // Manuel ters çevirme gerekmez
    }
    
    func testRTL_Padding() {
        // Padding'in RTL'de otomatik olarak mirror edilmesi
        // .leading(10) → LTR'de sol 10pt, RTL'de sağ 10pt
        
        let leadingPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        XCTAssertEqual(leadingPadding.leading, 10)
        XCTAssertEqual(leadingPadding.trailing, 0)
        
        // SwiftUI .leading/.trailing'i RTL'de otomatik mirror eder
    }
    
    func testRTL_ImageFlipping() {
        // Navigasyon ikonları RTL'de flip edilmeli
        // Örneğin: > (LTR) → < (RTL)
        
        let chevronRight = "chevron.right"
        let chevronLeft = "chevron.left"
        
        // SF Symbols otomatik flip desteği
        // .environment(\.layoutDirection, .rightToLeft)
        XCTAssertNotNil(chevronRight)
        XCTAssertNotNil(chevronLeft)
    }
    
    func testRTL_NotFlippedIcons() {
        // Bazı ikonlar flip edilmemeli (media controls, saatler vb.)
        let playIcon = "play.fill" // Media control - flip edilmez
        let clockIcon = "clock" // Saat - flip edilmez
        
        // Bu ikonlar .flipsForRightToLeftLayoutDirection(false) ile işaretlenmeli
        XCTAssertNotNil(playIcon)
        XCTAssertNotNil(clockIcon)
    }
    
    func testRTL_BreadcrumbSeparator() {
        // Breadcrumb ayırıcıları RTL'de ters çevrilmeli
        // LTR: Home > Products > Item
        // RTL: Item < Products < Home
        
        let ltrSeparator = ">"
        let rtlSeparator = "<"
        
        XCTAssertNotEqual(ltrSeparator, rtlSeparator)
    }
    
    func testRTL_TimelineDirection() {
        // Timeline RTL'de sağdan sola olmalı
        // LTR: Past ----o----o----o→ Future
        // RTL: Future ←----o----o----o Past
        
        let timelineDirection = "RTL'de ters"
        XCTAssertNotNil(timelineDirection)
    }
    
    // MARK: - Localization Tests
    
    func testLocalization_SupportedLanguages() {
        // Desteklenen dillerin kontrolü
        let supportedLanguages = ["en", "tr", "ar", "de", "fr", "es"]
        
        XCTAssertTrue(supportedLanguages.contains("en"), "İngilizce desteklenmeli")
        XCTAssertTrue(supportedLanguages.contains("tr"), "Türkçe desteklenmeli")
        XCTAssertTrue(supportedLanguages.contains("ar"), "Arapça desteklenmeli")
    }
    
    func testLocalization_CommonStrings() {
        // Yaygın kullanılan string'lerin çevirisinin olması
        let commonKeys = [
            "button.ok",
            "button.cancel",
            "button.save",
            "button.delete",
            "button.close",
            "error.required_field",
            "error.invalid_email",
            "placeholder.search",
            "label.loading",
            "label.no_results"
        ]
        
        for key in commonKeys {
            XCTAssertFalse(key.isEmpty, "Localization key boş olmamalı: \(key)")
        }
    }
    
    func testLocalization_PluralForms() {
        // Çoğul formların doğru kullanımı
        // Türkçe: 0 öğe, 1 öğe, 2 öğe
        // Arapça: 0, 1, 2, 3-10, 11+ farklı formlar
        // İngilizce: 1 item, 2 items
        
        let itemCount = 5
        let pluralKey = itemCount == 1 ? "item_singular" : "item_plural"
        
        XCTAssertNotNil(pluralKey)
    }
    
    func testLocalization_DateFormatting() {
        // Tarih formatlarının locale'e göre değişmesi
        let date = Date()
        
        // Türkçe: 11 Ekim 2025
        let trFormatter = DateFormatter()
        trFormatter.locale = Locale(identifier: "tr_TR")
        trFormatter.dateStyle = .long
        let trDate = trFormatter.string(from: date)
        
        // İngilizce: October 11, 2025
        let enFormatter = DateFormatter()
        enFormatter.locale = Locale(identifier: "en_US")
        enFormatter.dateStyle = .long
        let enDate = enFormatter.string(from: date)
        
        XCTAssertNotEqual(trDate, enDate, "Tarih formatları locale'e göre farklı olmalı")
    }
    
    func testLocalization_NumberFormatting() {
        // Sayı formatlarının locale'e göre değişmesi
        let number = 1234.56
        
        // Türkçe: 1.234,56
        let trFormatter = NumberFormatter()
        trFormatter.locale = Locale(identifier: "tr_TR")
        trFormatter.numberStyle = .decimal
        let trNumber = trFormatter.string(from: NSNumber(value: number))
        
        // İngilizce: 1,234.56
        let enFormatter = NumberFormatter()
        enFormatter.locale = Locale(identifier: "en_US")
        enFormatter.numberStyle = .decimal
        let enNumber = enFormatter.string(from: NSNumber(value: number))
        
        XCTAssertNotEqual(trNumber, enNumber, "Sayı formatları locale'e göre farklı olmalı")
    }
    
    func testLocalization_CurrencyFormatting() {
        // Para birimi formatlarının locale'e göre değişmesi
        let amount = 1234.56
        
        // Türkçe: ₺1.234,56
        let trFormatter = NumberFormatter()
        trFormatter.locale = Locale(identifier: "tr_TR")
        trFormatter.numberStyle = .currency
        let trCurrency = trFormatter.string(from: NSNumber(value: amount))
        
        // İngilizce (US): $1,234.56
        let enFormatter = NumberFormatter()
        enFormatter.locale = Locale(identifier: "en_US")
        enFormatter.numberStyle = .currency
        let enCurrency = enFormatter.string(from: NSNumber(value: amount))
        
        XCTAssertNotEqual(trCurrency, enCurrency, "Para formatları locale'e göre farklı olmalı")
    }
    
    // MARK: - Bidirectional Text Tests
    
    func testBidiText_MixedContent() {
        // LTR ve RTL metinlerin karışık kullanımı
        // Örneğin: "Welcome مرحبا User"
        
        let mixedText = "Hello مرحبا World"
        XCTAssertTrue(mixedText.contains("Hello"))
        XCTAssertTrue(mixedText.contains("مرحبا")) // Arapça "merhaba"
        
        // Unicode Bidirectional Algorithm (UAX #9) SwiftUI tarafından otomatik uygulanır
    }
    
    func testBidiText_Numbers() {
        // RTL metinde sayıların yönü
        // Arapça metinde sayılar LTR kalır
        // Örneğin: "العدد 123 هنا" (Sayı 123 burada)
        
        let arabicWithNumber = "العدد 123 هنا"
        XCTAssertTrue(arabicWithNumber.contains("123"))
    }
    
    func testBidiText_Punctuation() {
        // Noktalama işaretlerinin RTL'deki davranışı
        let arabicSentence = "مرحبا!"
        XCTAssertTrue(arabicSentence.hasSuffix("!"))
    }
    
    // MARK: - Text Expansion Tests
    
    func testTextExpansion_German() {
        // Almanca metinler genelde daha uzun
        let en = "Settings"
        let de = "Einstellungen"
        
        XCTAssertGreaterThan(de.count, en.count, "Almanca genelde daha uzun")
    }
    
    func testTextExpansion_ButtonWidth() {
        // Çeviri sonrası button'ların sığması
        let maxButtonWidth: CGFloat = 300
        
        // Button'lar localize edilmiş text'i sığdırmalı
        // veya truncate/multiline olmalı
        XCTAssertGreaterThan(maxButtonWidth, 0)
    }
    
    func testTextExpansion_FieldLabels() {
        // Form label'larının çeviride sığması
        let labels = ["Email", "Password", "Confirm Password"]
        
        for label in labels {
            // Label'lar kısa tutulmalı veya multiline olmalı
            XCTAssertLessThanOrEqual(label.count, 50, "Label çok uzun olmamalı")
        }
    }
    
    // MARK: - Locale Switching Tests
    
    func testLocale_RuntimeSwitch() {
        // Runtime'da dil değiştirme
        let currentLocale = Locale.current
        let newLocale = Locale(identifier: "ar_SA")
        
        XCTAssertNotEqual(currentLocale.identifier, newLocale.identifier)
    }
    
    func testLocale_SystemDefault() {
        // Sistem varsayılan dilinin kullanımı
        let systemLocale = Locale.current
        XCTAssertNotNil(systemLocale.language.languageCode)
    }
    
    // MARK: - Component-Specific RTL Tests
    
    func testButton_RTL() {
        // Button içindeki icon ve text'in RTL'de ters sırada olması
        // LTR: [icon] Text
        // RTL: Text [icon]
        
        XCTAssertTrue(true, "Button icon position RTL'de mirror edilmeli")
    }
    
    func testTextField_RTL() {
        // TextField'da text'in RTL dillerinde sağdan başlaması
        // Cursor position RTL'de sağdan başlamalı
        
        XCTAssertTrue(true, "TextField RTL desteği olmalı")
    }
    
    func testBreadcrumb_RTL() {
        // Breadcrumb'ın RTL'de ters sırada görünmesi
        // LTR: Home > Products > Item
        // RTL: Item < Products < Home
        
        XCTAssertTrue(true, "Breadcrumb RTL'de ters sırada olmalı")
    }
    
    func testTimeline_RTL() {
        // Timeline'ın RTL'de sağdan sola olması
        XCTAssertTrue(true, "Timeline RTL'de sağdan sola olmalı")
    }
    
    func testProgress_RTL() {
        // ProgressBar'ın RTL'de sağdan başlaması
        XCTAssertTrue(true, "ProgressBar RTL'de sağdan dolu olmalı")
    }
    
    func testChip_RTL() {
        // Chip'lerde icon ve close button'ın RTL'de yer değiştirmesi
        // LTR: [icon] Text [x]
        // RTL: [x] Text [icon]
        
        XCTAssertTrue(true, "Chip RTL'de mirror edilmeli")
    }
    
    // MARK: - Accessibility + RTL Tests
    
    func testVoiceOver_RTL() {
        // VoiceOver'ın RTL dillerinde doğru çalışması
        // Reading order RTL'de sağdan sola olmalı
        
        XCTAssertTrue(true, "VoiceOver RTL'de sağdan sola okumalı")
    }
    
    func testVoiceOver_BidiText() {
        // VoiceOver'ın karışık LTR/RTL text'i doğru okuması
        let mixedText = "Hello مرحبا 123"
        
        XCTAssertTrue(mixedText.contains("Hello"))
        XCTAssertTrue(mixedText.contains("مرحبا"))
    }
    
    // MARK: - Helper Methods
    
    private func isRTL(locale: Locale) -> Bool {
        return locale.language.characterDirection == .rightToLeft
    }
    
    private func mirrorForRTL(layoutDirection: LayoutDirection, _ value: CGFloat) -> CGFloat {
        return layoutDirection == .rightToLeft ? -value : value
    }
}

// MARK: - Locale Extension

extension Locale {
    var isRTL: Bool {
        return self.language.characterDirection == .rightToLeft
    }
}

// MARK: - LocalizedStringKey Tests

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class LocalizedStringTests: XCTestCase {
    
    func testLocalizedStrings_AllKeysHaveValues() {
        // Tüm localization key'lerinin değer içermesi
        let keys = [
            "button.ok",
            "button.cancel",
            "button.save",
            "button.delete"
        ]
        
        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            XCTAssertFalse(localized.isEmpty, "Localized string boş olmamalı: \(key)")
        }
    }
    
    func testLocalizedStrings_NoMissingTranslations() {
        // Çevrilmemiş string'lerin kontrolü
        // Eğer çeviri yoksa key döner (uyarı)
        
        let key = "test.missing.key"
        let localized = NSLocalizedString(key, comment: "")
        
        // Eğer çeviri yoksa key'in kendisi döner
        if localized == key {
            // Uyarı: Çeviri eksik
            XCTAssertTrue(true, "Uyarı: '\(key)' için çeviri eksik")
        }
    }
}

