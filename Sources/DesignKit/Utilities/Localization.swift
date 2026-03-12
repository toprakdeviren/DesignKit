import SwiftUI

// MARK: - Localization Manager

/// Localization manager for DesignKit
public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    @Published public var currentLocale: Locale = .current
    @Published public var currentLanguage: Language = .system
    
    private init() {
        detectSystemLanguage()
    }
    
    public enum Language: String, CaseIterable {
        case system = "system"
        case turkish = "tr"
        case english = "en"
        case arabic = "ar"
        case german = "de"
        case french = "fr"
        case spanish = "es"
        
        public var displayName: String {
            switch self {
            case .system: return "Sistem"
            case .turkish: return "Türkçe"
            case .english: return "English"
            case .arabic: return "العربية"
            case .german: return "Deutsch"
            case .french: return "Français"
            case .spanish: return "Español"
            }
        }
        
        public var isRTL: Bool {
            return self == .arabic
        }
    }
    
    private func detectSystemLanguage() {
        guard let languageCode = Locale.current.language.languageCode?.identifier else {
            currentLanguage = .system
            return
        }
        
        currentLanguage = Language(rawValue: languageCode) ?? .system
    }
    
    public func setLanguage(_ language: Language) {
        currentLanguage = language
        
        if language == .system {
            detectSystemLanguage()
        }
    }
}

// MARK: - Localized Strings

public struct LocalizedString {
    // Common
    public static let ok = "ok"
    public static let cancel = "cancel"
    public static let save = "save"
    public static let delete = "delete"
    public static let edit = "edit"
    public static let done = "done"
    public static let close = "close"
    public static let back = "back"
    public static let next = "next"
    public static let previous = "previous"
    
    // Form
    public static let required = "required"
    public static let optional = "optional"
    public static let enterValue = "enter_value"
    public static let selectOption = "select_option"
    public static let search = "search"
    public static let filter = "filter"
    public static let sort = "sort"
    
    // Date & Time
    public static let today = "today"
    public static let yesterday = "yesterday"
    public static let tomorrow = "tomorrow"
    public static let selectDate = "select_date"
    public static let selectTime = "select_time"
    
    // File Upload
    public static let uploadFile = "upload_file"
    public static let dragAndDrop = "drag_and_drop"
    public static let selectFile = "select_file"
    public static let maxFileSize = "max_file_size"
    public static let allowedTypes = "allowed_types"
    
    // Validation
    public static let invalidEmail = "invalid_email"
    public static let invalidPhone = "invalid_phone"
    public static let passwordTooShort = "password_too_short"
    public static let fieldRequired = "field_required"
    
    // Loading
    public static let loading = "loading"
    public static let pleaseWait = "please_wait"
    public static let loadingMore = "loading_more"
    public static let allLoaded = "all_loaded"
    
    // Errors
    public static let errorOccurred = "error_occurred"
    public static let tryAgain = "try_again"
    public static let somethingWentWrong = "something_went_wrong"
}

// MARK: - String Extension for Localization

extension String {
    /// Localize string
    public func localized(language: LocalizationManager.Language = LocalizationManager.shared.currentLanguage) -> String {
        let translations = LocalizationData.translations
        
        if language == .system {
            return NSLocalizedString(self, comment: "")
        }
        
        return translations[language.rawValue]?[self] ?? self
    }
}

// MARK: - Localization Data

struct LocalizationData {
    static let translations: [String: [String: String]] = [
        "tr": [
            // Common
            "ok": "Tamam",
            "cancel": "İptal",
            "save": "Kaydet",
            "delete": "Sil",
            "edit": "Düzenle",
            "done": "Bitti",
            "close": "Kapat",
            "back": "Geri",
            "next": "İleri",
            "previous": "Önceki",
            
            // Form
            "required": "Zorunlu",
            "optional": "İsteğe Bağlı",
            "enter_value": "Değer girin",
            "select_option": "Seçenek seçin",
            "search": "Ara",
            "filter": "Filtrele",
            "sort": "Sırala",
            
            // Date & Time
            "today": "Bugün",
            "yesterday": "Dün",
            "tomorrow": "Yarın",
            "select_date": "Tarih Seç",
            "select_time": "Saat Seç",
            
            // File Upload
            "upload_file": "Dosya Yükle",
            "drag_and_drop": "Dosyayı sürükleyip bırakın",
            "select_file": "Dosya Seç",
            "max_file_size": "Maksimum dosya boyutu",
            "allowed_types": "İzin verilen tipler",
            
            // Validation
            "invalid_email": "Geçersiz e-posta adresi",
            "invalid_phone": "Geçersiz telefon numarası",
            "password_too_short": "Şifre çok kısa",
            "field_required": "Bu alan zorunludur",
            
            // Loading
            "loading": "Yükleniyor",
            "please_wait": "Lütfen bekleyin",
            "loading_more": "Daha fazla yükleniyor",
            "all_loaded": "Tümü yüklendi",
            
            // Errors
            "error_occurred": "Bir hata oluştu",
            "try_again": "Tekrar deneyin",
            "something_went_wrong": "Bir şeyler ters gitti"
        ],
        
        "en": [
            // Common
            "ok": "OK",
            "cancel": "Cancel",
            "save": "Save",
            "delete": "Delete",
            "edit": "Edit",
            "done": "Done",
            "close": "Close",
            "back": "Back",
            "next": "Next",
            "previous": "Previous",
            
            // Form
            "required": "Required",
            "optional": "Optional",
            "enter_value": "Enter value",
            "select_option": "Select option",
            "search": "Search",
            "filter": "Filter",
            "sort": "Sort",
            
            // Date & Time
            "today": "Today",
            "yesterday": "Yesterday",
            "tomorrow": "Tomorrow",
            "select_date": "Select Date",
            "select_time": "Select Time",
            
            // File Upload
            "upload_file": "Upload File",
            "drag_and_drop": "Drag and drop file",
            "select_file": "Select File",
            "max_file_size": "Maximum file size",
            "allowed_types": "Allowed types",
            
            // Validation
            "invalid_email": "Invalid email address",
            "invalid_phone": "Invalid phone number",
            "password_too_short": "Password too short",
            "field_required": "This field is required",
            
            // Loading
            "loading": "Loading",
            "please_wait": "Please wait",
            "loading_more": "Loading more",
            "all_loaded": "All loaded",
            
            // Errors
            "error_occurred": "An error occurred",
            "try_again": "Try again",
            "something_went_wrong": "Something went wrong"
        ],
        
        "ar": [
            // Common
            "ok": "موافق",
            "cancel": "إلغاء",
            "save": "حفظ",
            "delete": "حذف",
            "edit": "تعديل",
            "done": "تم",
            "close": "إغلاق",
            "back": "رجوع",
            "next": "التالي",
            "previous": "السابق",
            
            // Form
            "required": "مطلوب",
            "optional": "اختياري",
            "enter_value": "أدخل القيمة",
            "select_option": "حدد خياراً",
            "search": "بحث",
            "filter": "تصفية",
            "sort": "ترتيب"
        ]
    ]
}

// MARK: - RTL Support

/// RTL (Right-to-Left) layout helper
public struct RTLHelper {
    
    /// Check if current language is RTL
    public static var isRTL: Bool {
        LocalizationManager.shared.currentLanguage.isRTL
    }
    
    /// Get text alignment based on RTL
    public static var textAlignment: TextAlignment {
        isRTL ? .trailing : .leading
    }
    
    /// Get horizontal alignment based on RTL
    public static var horizontalAlignment: HorizontalAlignment {
        isRTL ? .trailing : .leading
    }
    
    /// Flip edge for RTL
    public static func edge(_ edge: Edge) -> Edge {
        guard isRTL else { return edge }
        
        switch edge {
        case .leading: return .trailing
        case .trailing: return .leading
        default: return edge
        }
    }
}

// MARK: - View Extensions for RTL

extension View {
    /// Apply RTL-aware alignment
    public func rtlAlignment() -> some View {
        frame(maxWidth: .infinity, alignment: RTLHelper.isRTL ? .trailing : .leading)
    }
    
    /// Apply RTL-aware padding
    public func rtlPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        if RTLHelper.isRTL {
            let flippedEdges: Edge.Set = {
                var result: Edge.Set = []
                if edges.contains(.leading) { result.insert(.trailing) }
                if edges.contains(.trailing) { result.insert(.leading) }
                if edges.contains(.top) { result.insert(.top) }
                if edges.contains(.bottom) { result.insert(.bottom) }
                return result
            }()
            return padding(flippedEdges, length)
        } else {
            return padding(edges, length)
        }
    }
    
    /// Mirror view for RTL
    public func mirrorForRTL() -> some View {
        scaleEffect(x: RTLHelper.isRTL ? -1 : 1, y: 1)
    }
    
    /// Apply environment for RTL
    public func rtlEnvironment() -> some View {
        environment(\.layoutDirection, RTLHelper.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - Language Picker Component

public struct DKLanguagePicker: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        Picker("Language", selection: $localizationManager.currentLanguage) {
            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
            }
        }
        .pickerStyle(.menu)
    }
}

// MARK: - Preview
#if DEBUG
struct RTLDemo: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DKLanguagePicker()
            
            VStack(alignment: RTLHelper.horizontalAlignment, spacing: 8) {
                Text(LocalizedString.ok.localized())
                Text(LocalizedString.cancel.localized())
                Text(LocalizedString.save.localized())
                Text(LocalizedString.delete.localized())
            }
            .rtlAlignment()
            
            HStack {
                Image(systemName: "arrow.forward")
                    .mirrorForRTL()
                Text("Direction Arrow")
            }
        }
        .padding()
        .rtlEnvironment()
    }
}

struct DKLocalization_Previews: PreviewProvider {
    static var previews: some View {
        RTLDemo()
    }
}
#endif

