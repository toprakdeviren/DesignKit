import XCTest
import SwiftUI
@testable import DesignKit

final class LocalizationTests: XCTestCase {
    
    var localization: DKLocalization!
    
    override func setUp() {
        super.setUp()
        localization = DKLocalization.shared
    }
    
    // MARK: - Basic Translation Tests
    
    func testTranslationEnglish() {
        localization.setLanguage(.english)
        let translation = localization.translate("common.ok")
        XCTAssertEqual(translation, "OK")
    }
    
    func testTranslationTurkish() {
        localization.setLanguage(.turkish)
        let translation = localization.translate("common.ok")
        XCTAssertEqual(translation, "Tamam")
    }
    
    func testTranslationArabic() {
        localization.setLanguage(.arabic)
        let translation = localization.translate("common.ok")
        XCTAssertEqual(translation, "حسنا")
    }
    
    func testTranslationFallback() {
        localization.setLanguage(.english)
        let translation = localization.translate("nonexistent.key", defaultValue: "Fallback")
        XCTAssertEqual(translation, "Fallback")
    }
    
    func testTranslationWithoutDefault() {
        localization.setLanguage(.english)
        let translation = localization.translate("nonexistent.key")
        XCTAssertEqual(translation, "nonexistent.key")
    }
    
    // MARK: - Language Tests
    
    func testSupportedLanguages() {
        let languages = DKLocalization.SupportedLanguage.allCases
        XCTAssertFalse(languages.isEmpty)
        XCTAssertTrue(languages.count >= 10)
    }
    
    func testLanguageDisplayNames() {
        XCTAssertEqual(DKLocalization.SupportedLanguage.english.displayName, "English")
        XCTAssertEqual(DKLocalization.SupportedLanguage.turkish.displayName, "Türkçe")
        XCTAssertEqual(DKLocalization.SupportedLanguage.arabic.displayName, "العربية")
    }
    
    func testRTLLanguages() {
        XCTAssertTrue(DKLocalization.SupportedLanguage.arabic.isRTL)
        XCTAssertTrue(DKLocalization.SupportedLanguage.hebrew.isRTL)
        XCTAssertFalse(DKLocalization.SupportedLanguage.english.isRTL)
        XCTAssertFalse(DKLocalization.SupportedLanguage.turkish.isRTL)
    }
    
    func testSetLanguage() {
        localization.setLanguage(.turkish)
        XCTAssertEqual(localization.currentLanguage, "tr")
        
        localization.setLanguage(.english)
        XCTAssertEqual(localization.currentLanguage, "en")
    }
    
    // MARK: - RTL Layout Tests
    
    func testLayoutDirectionRTL() {
        localization.setLanguage(.arabic)
        XCTAssertEqual(localization.layoutDirection, .rightToLeft)
    }
    
    func testLayoutDirectionLTR() {
        localization.setLanguage(.english)
        XCTAssertEqual(localization.layoutDirection, .leftToRight)
        
        localization.setLanguage(.turkish)
        XCTAssertEqual(localization.layoutDirection, .leftToRight)
    }
    
    func testLocaleIsRightToLeft() {
        let arabicLocale = Locale(identifier: "ar")
        XCTAssertTrue(arabicLocale.isRightToLeft)
        
        let englishLocale = Locale(identifier: "en")
        XCTAssertFalse(englishLocale.isRightToLeft)
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormatDate() {
        localization.setLanguage(.english)
        let date = Date()
        let formatted = localization.formatDate(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatTime() {
        localization.setLanguage(.english)
        let date = Date()
        let formatted = localization.formatTime(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatDateTime() {
        localization.setLanguage(.english)
        let date = Date()
        let formatted = localization.formatDateTime(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatRelativeDate() {
        localization.setLanguage(.english)
        let date = Date()
        let formatted = localization.formatRelativeDate(date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testDateLocalization() {
        let date = Date()
        let localized = date.localizedString()
        XCTAssertFalse(localized.isEmpty)
    }
    
    func testRelativeDateString() {
        let date = Date()
        let relative = date.relativeString
        XCTAssertFalse(relative.isEmpty)
    }
    
    // MARK: - Number Formatting Tests
    
    func testFormatNumber() {
        localization.setLanguage(.english)
        let formatted = localization.formatNumber(1234.56)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatCurrency() {
        localization.setLanguage(.english)
        let formatted = localization.formatCurrency(99.99, currencyCode: "USD")
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatPercentage() {
        localization.setLanguage(.english)
        let formatted = localization.formatPercentage(0.75)
        XCTAssertTrue(formatted.contains("%"))
    }
    
    // MARK: - Custom Translations Tests
    
    func testAddCustomTranslations() {
        let customTranslations = [
            "custom.key": "Custom Value"
        ]
        
        localization.addTranslations(for: "en", translations: customTranslations)
        localization.setLanguage(.english)
        
        let translation = localization.translate("custom.key")
        XCTAssertEqual(translation, "Custom Value")
    }
    
    func testOverrideTranslations() {
        localization.addTranslations(for: "en", translations: [
            "common.ok": "Okay"
        ])
        localization.setLanguage(.english)
        
        let translation = localization.translate("common.ok")
        XCTAssertEqual(translation, "Okay")
    }
    
    // MARK: - String Extension Tests
    
    func testStringLocalization() {
        localization.setLanguage(.turkish)
        let localized = "common.cancel".localized
        XCTAssertEqual(localized, "İptal")
    }
    
    func testStringLocalizationWithArgs() {
        localization.addTranslations(for: "en", translations: [
            "greeting": "Hello, %@!"
        ])
        localization.setLanguage(.english)
        
        let localized = "greeting".localized("World")
        XCTAssertEqual(localized, "Hello, World!")
    }
    
    // MARK: - Common Translations Tests
    
    func testCommonTranslations() {
        localization.setLanguage(.english)
        
        XCTAssertEqual(localization.translate("common.ok"), "OK")
        XCTAssertEqual(localization.translate("common.cancel"), "Cancel")
        XCTAssertEqual(localization.translate("common.save"), "Save")
        XCTAssertEqual(localization.translate("common.delete"), "Delete")
    }
    
    func testFormTranslations() {
        localization.setLanguage(.english)
        
        XCTAssertEqual(localization.translate("form.required"), "Required")
        XCTAssertEqual(localization.translate("form.optional"), "Optional")
        XCTAssertEqual(localization.translate("form.email"), "Email")
    }
    
    func testDateTranslations() {
        localization.setLanguage(.english)
        
        XCTAssertEqual(localization.translate("date.today"), "Today")
        XCTAssertEqual(localization.translate("date.yesterday"), "Yesterday")
        XCTAssertEqual(localization.translate("date.tomorrow"), "Tomorrow")
    }
}

