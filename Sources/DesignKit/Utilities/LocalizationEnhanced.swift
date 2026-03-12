import SwiftUI
import Foundation

/// Enhanced localization system with i18n support, RTL layout, and locale-aware formatting
public final class DKLocalization: ObservableObject {
    
    // MARK: - Singleton
    
    public static let shared = DKLocalization()
    
    // MARK: - Properties
    
    @Published public var currentLocale: Locale {
        didSet {
            updateDirectionality()
        }
    }
    
    @Published public var currentLanguage: String {
        didSet {
            currentLocale = Locale(identifier: currentLanguage)
        }
    }
    
    @Published public var layoutDirection: LayoutDirection = .leftToRight
    
    private var translations: [String: [String: String]] = [:]
    
    // MARK: - Supported Languages
    
    public enum SupportedLanguage: String, CaseIterable, Identifiable {
        case english = "en"
        case turkish = "tr"
        case arabic = "ar"
        case hebrew = "he"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case japanese = "ja"
        case chinese = "zh"
        case russian = "ru"
        
        public var id: String { rawValue }
        
        public var displayName: String {
            switch self {
            case .english: return "English"
            case .turkish: return "Türkçe"
            case .arabic: return "العربية"
            case .hebrew: return "עברית"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .japanese: return "日本語"
            case .chinese: return "中文"
            case .russian: return "Русский"
            }
        }
        
        public var isRTL: Bool {
            self == .arabic || self == .hebrew
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        self.currentLanguage = systemLanguage
        self.currentLocale = Locale.current
        
        updateDirectionality()
        loadDefaultTranslations()
    }
    
    // MARK: - Translation Methods
    
    /// Get translated string for key
    public func translate(_ key: String, defaultValue: String? = nil) -> String {
        if let languageTranslations = translations[currentLanguage],
           let translation = languageTranslations[key] {
            return translation
        }
        
        // Fallback to English
        if currentLanguage != "en",
           let englishTranslations = translations["en"],
           let translation = englishTranslations[key] {
            return translation
        }
        
        return defaultValue ?? key
    }
    
    /// Get translated string with interpolation
    public func translate(_ key: String, args: CVarArg..., defaultValue: String? = nil) -> String {
        let template = translate(key, defaultValue: defaultValue)
        return String(format: template, arguments: args)
    }
    
    /// Add translations for a language
    public func addTranslations(for language: String, translations: [String: String]) {
        if self.translations[language] == nil {
            self.translations[language] = [:]
        }
        self.translations[language]?.merge(translations) { _, new in new }
    }
    
    /// Load translations from JSON file
    public func loadTranslations(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([String: [String: String]].self, from: data)
        
        for (language, translations) in decoded {
            addTranslations(for: language, translations: translations)
        }
    }
    
    // MARK: - Language & Direction
    
    /// Change current language
    public func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language.rawValue
    }
    
    /// Update layout direction based on current language
    private func updateDirectionality() {
        if let languageCode = currentLocale.language.languageCode?.identifier,
           let supportedLanguage = SupportedLanguage(rawValue: languageCode) {
            layoutDirection = supportedLanguage.isRTL ? .rightToLeft : .leftToRight
        } else {
            layoutDirection = .leftToRight
        }
    }
    
    // MARK: - Default Translations
    
    private func loadDefaultTranslations() {
        // English
        addTranslations(for: "en", translations: [
            // Common
            "common.ok": "OK",
            "common.cancel": "Cancel",
            "common.save": "Save",
            "common.delete": "Delete",
            "common.edit": "Edit",
            "common.close": "Close",
            "common.back": "Back",
            "common.next": "Next",
            "common.done": "Done",
            "common.loading": "Loading...",
            "common.error": "Error",
            "common.success": "Success",
            "common.warning": "Warning",
            
            // Forms
            "form.required": "Required",
            "form.optional": "Optional",
            "form.email": "Email",
            "form.password": "Password",
            "form.username": "Username",
            "form.search": "Search",
            
            // Dates
            "date.today": "Today",
            "date.yesterday": "Yesterday",
            "date.tomorrow": "Tomorrow",
            
            // Components
            "file.upload": "Upload File",
            "file.drop": "Drop files here",
            "color.picker": "Pick a Color",
            "calendar.select": "Select Date"
        ])
        
        // Turkish
        addTranslations(for: "tr", translations: [
            // Common
            "common.ok": "Tamam",
            "common.cancel": "İptal",
            "common.save": "Kaydet",
            "common.delete": "Sil",
            "common.edit": "Düzenle",
            "common.close": "Kapat",
            "common.back": "Geri",
            "common.next": "İleri",
            "common.done": "Bitti",
            "common.loading": "Yükleniyor...",
            "common.error": "Hata",
            "common.success": "Başarılı",
            "common.warning": "Uyarı",
            
            // Forms
            "form.required": "Zorunlu",
            "form.optional": "İsteğe Bağlı",
            "form.email": "E-posta",
            "form.password": "Şifre",
            "form.username": "Kullanıcı Adı",
            "form.search": "Ara",
            
            // Dates
            "date.today": "Bugün",
            "date.yesterday": "Dün",
            "date.tomorrow": "Yarın",
            
            // Components
            "file.upload": "Dosya Yükle",
            "file.drop": "Dosyaları buraya bırakın",
            "color.picker": "Renk Seç",
            "calendar.select": "Tarih Seç"
        ])
        
        // Arabic
        addTranslations(for: "ar", translations: [
            "common.ok": "حسنا",
            "common.cancel": "إلغاء",
            "common.save": "حفظ",
            "common.delete": "حذف",
            "common.edit": "تعديل",
            "common.close": "إغلاق",
            "common.back": "رجوع",
            "common.next": "التالي",
            "common.done": "تم",
            "date.today": "اليوم",
            "date.yesterday": "أمس",
            "date.tomorrow": "غدا"
        ])
        
        // Hebrew
        addTranslations(for: "he", translations: [
            "common.ok": "אישור",
            "common.cancel": "ביטול",
            "common.save": "שמור",
            "common.delete": "מחק",
            "common.edit": "ערוך",
            "common.close": "סגור",
            "common.back": "חזור",
            "common.next": "הבא",
            "common.done": "סיום",
            "date.today": "היום",
            "date.yesterday": "אתמול",
            "date.tomorrow": "מחר"
        ])
    }
}

// MARK: - Locale-Aware Formatters

public extension DKLocalization {
    
    /// Format date with current locale
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Format time with current locale
    func formatTime(_ date: Date, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = .none
        formatter.timeStyle = style
        return formatter.string(from: date)
    }
    
    /// Format date and time with current locale
    func formatDateTime(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }
    
    /// Format relative date (e.g., "2 days ago")
    func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = currentLocale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// Format number with current locale
    func formatNumber(_ number: NSNumber, style: NumberFormatter.Style = .decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = style
        return formatter.string(from: number) ?? "\(number)"
    }
    
    /// Format currency with current locale
    func formatCurrency(_ amount: Double, currencyCode: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .currency
        
        if let currencyCode = currencyCode {
            formatter.currencyCode = currencyCode
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Format percentage with current locale
    func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value * 100)%"
    }
}

// MARK: - SwiftUI Environment

private struct LocalizationKey: EnvironmentKey {
    static let defaultValue = DKLocalization.shared
}

public extension EnvironmentValues {
    var dkLocalization: DKLocalization {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Apply RTL layout direction if needed
    func rtlSupport() -> some View {
        environment(\.layoutDirection, DKLocalization.shared.layoutDirection)
    }
    
    /// Set localization environment
    func localization(_ localization: DKLocalization) -> some View {
        environment(\.dkLocalization, localization)
            .environment(\.locale, localization.currentLocale)
            .environment(\.layoutDirection, localization.layoutDirection)
    }
}

// MARK: - String Extension

public extension String {
    /// Localize string using DKLocalization
    var localized: String {
        DKLocalization.shared.translate(self, defaultValue: self)
    }
    
    /// Localize string with arguments
    func localized(_ args: CVarArg...) -> String {
        let template = DKLocalization.shared.translate(self, defaultValue: self)
        return String(format: template, arguments: args)
    }
}

// MARK: - Locale Extensions

public extension Locale {
    /// Check if locale uses RTL layout
    var isRightToLeft: Bool {
        guard let languageCode = language.languageCode?.identifier else { return false }
        return ["ar", "he", "fa", "ur"].contains(languageCode)
    }
}

// MARK: - Date Extensions

public extension Date {
    /// Format date with current localization
    func localizedString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        DKLocalization.shared.formatDateTime(self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    /// Format as relative date
    var relativeString: String {
        DKLocalization.shared.formatRelativeDate(self)
    }
}

