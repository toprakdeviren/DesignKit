import Foundation

// MARK: - Localization Key Enum

/// All user-facing string keys produced by DesignKit components.
///
/// Instead of hardcoding language-specific strings inside components,
/// every string is looked up through this enum so host apps can:
/// 1. Rely on the built-in English defaults (zero config)
/// 2. Override any key via a `Localizable.strings` file in their bundle
/// 3. Swap the lookup bundle at runtime (e.g. per-user language)
///
/// ```swift
/// // In your app's Localizable.strings (tr):
/// "dk.validation.required" = "Bu alan zorunludur";
/// "dk.button.send"         = "Gönder";
/// ```
public enum DKLocalizationKey: String {

    // MARK: Form Validation
    case validationRequired         = "dk.validation.required"
    case validationEmail            = "dk.validation.email"
    case validationMinLength        = "dk.validation.min_length"         // arg: %d
    case validationMaxLength        = "dk.validation.max_length"         // arg: %d
    case validationPhone            = "dk.validation.phone"
    case validationURL              = "dk.validation.url"
    case validationAlphanumeric     = "dk.validation.alphanumeric"
    case validationPasswordStrength = "dk.validation.password_strength"
    case validationCustomDefault    = "dk.validation.custom_default"

    // MARK: Common Buttons
    case buttonCancel   = "dk.button.cancel"
    case buttonConfirm  = "dk.button.confirm"
    case buttonDelete   = "dk.button.delete"
    case buttonSave     = "dk.button.save"
    case buttonSend     = "dk.button.send"
    case buttonClose    = "dk.button.close"
    case buttonRetry    = "dk.button.retry"
    case buttonDone     = "dk.button.done"
    case buttonEdit     = "dk.button.edit"
    case buttonBack     = "dk.button.back"
    case buttonLoadMore = "dk.button.load_more"

    // MARK: Search
    case searchPlaceholder = "dk.search.placeholder"
    case searchNoResults   = "dk.search.no_results"
    case searchClear       = "dk.search.clear"

    // MARK: States
    case stateLoading  = "dk.state.loading"
    case stateEmpty    = "dk.state.empty"
    case stateError    = "dk.state.error"
    case stateRetry    = "dk.state.retry"

    // MARK: File Upload
    case fileUploadPrompt    = "dk.file_upload.prompt"
    case fileUploadBrowse    = "dk.file_upload.browse"
    case fileUploadRemoving  = "dk.file_upload.removing"
    case fileUploadSizeError = "dk.file_upload.size_error"    // arg: %@

    // MARK: Date / Time
    case dateToday     = "dk.date.today"
    case dateYesterday = "dk.date.yesterday"
    case dateJustNow   = "dk.date.just_now"                  // e.g. "just now"
    case dateMinutesAgo = "dk.date.minutes_ago"              // arg: %d

    // MARK: Accessibility — General
    case a11yAvatar           = "dk.a11y.avatar"
    case a11yAvatarGroup      = "dk.a11y.avatar_group"       // arg: %d
    case a11yClose            = "dk.a11y.close"
    case a11yBack             = "dk.a11y.back"
    case a11yBadgeCount       = "dk.a11y.badge_count"        // arg: %d
    case a11yOnline           = "dk.a11y.online"
    case a11yOffline          = "dk.a11y.offline"
    case a11yBusy             = "dk.a11y.busy"
    case a11yAway             = "dk.a11y.away"
    case a11yLoading          = "dk.a11y.loading"
    case a11ySelected         = "dk.a11y.selected"
    case a11yNotSelected      = "dk.a11y.not_selected"
    case a11yDoubleTapRemove  = "dk.a11y.double_tap_remove"
    case a11yClearSearch      = "dk.a11y.clear_search"
    case a11ySearch           = "dk.a11y.search"

    // MARK: Accessibility — Component Specific
    case a11yRatingValue  = "dk.a11y.rating_value"           // args: %d, %d
    case a11yRatingStars  = "dk.a11y.rating_stars"           // "Rating"
    case a11yProgress     = "dk.a11y.progress"               // arg: %d (percent)
    case a11yProgressBar  = "dk.a11y.progress_bar"           // "Progress"
    case a11ySwitchLabel  = "dk.a11y.switch"
    case a11ySwitchOn     = "dk.a11y.switch_on"
    case a11ySwitchOff    = "dk.a11y.switch_off"
    case a11yTimePicker   = "dk.a11y.time_picker"
    case a11yDatePicker   = "dk.a11y.date_picker"
    case a11yFileUpload   = "dk.a11y.file_upload"
    case a11yTimeline     = "dk.a11y.timeline"
    case a11yBreadcrumb   = "dk.a11y.breadcrumb"
    case a11yColorPicker  = "dk.a11y.color_picker"
    case a11yReactions    = "dk.a11y.reactions"              // "reactions"
    case a11yTabSelected  = "dk.a11y.tab_selected"
    case a11yTabSelectHint = "dk.a11y.tab_select_hint"
    case a11yTabUnread    = "dk.a11y.tab_unread"             // arg: %d

    // MARK: File Upload — UI Strings
    case fileUploadDrop      = "dk.file_upload.drop"         // "Drop files here"
    case fileUploadTap       = "dk.file_upload.tap"          // "Tap to upload"
    case fileUploadFileCount = "dk.file_upload.file_count"   // arg: %d
    case fileUploadMaxFiles  = "dk.file_upload.max_files"    // arg: %d
    case fileUploadTooLarge  = "dk.file_upload.too_large"    // args: %@, %@
    case fileUploadError     = "dk.file_upload.error"        // arg: %@
    case fileUploadFormats   = "dk.file_upload.formats"      // arg: %@
    case fileUploadMaxSize   = "dk.file_upload.max_size"     // arg: %@

    // MARK: Toast / Alert
    case toastInfo    = "dk.toast.info"
    case toastSuccess = "dk.toast.success"
    case toastWarning = "dk.toast.warning"
    case toastError   = "dk.toast.error"
}

// MARK: - Localizer

/// Central lookup helper used by all DesignKit components.
///
/// Host apps can call `DKLocalizer.configure(bundle:)` to point DesignKit
/// at their own bundle (and therefore their own `Localizable.strings`).
public final class DKLocalizer {

    // MARK: Configuration

    /// The bundle used for string lookup.
    /// Defaults to the main bundle so host apps typically don't need to configure this.
    public static var bundle: Bundle = .main

    /// Optional table name (Localizable.strings file name without extension).
    /// Defaults to `"Localizable"`.
    public static var tableName: String = "Localizable"

    // MARK: Look-up

    /// Returns the localized string for a key, with a sensible English fallback.
    public static func string(for key: DKLocalizationKey) -> String {
        let looked = NSLocalizedString(
            key.rawValue,
            tableName: tableName,
            bundle: bundle,
            value: "",
            comment: ""
        )
        // If the host app didn't provide a translation, fall back to built-in English.
        return looked.isEmpty ? defaultValue(for: key) : looked
    }

    /// Formatted variant — replaces `%d` / `%@` placeholders.
    public static func string(for key: DKLocalizationKey, _ args: CVarArg...) -> String {
        String(format: string(for: key), arguments: args)
    }

    // MARK: Built-in English Defaults

    // swiftlint:disable cyclomatic_complexity function_body_length
    private static func defaultValue(for key: DKLocalizationKey) -> String {
        switch key {
        // Form Validation
        case .validationRequired:         return "This field is required"
        case .validationEmail:            return "Please enter a valid email address"
        case .validationMinLength:        return "Must be at least %d characters"
        case .validationMaxLength:        return "Must be at most %d characters"
        case .validationPhone:            return "Please enter a valid phone number"
        case .validationURL:              return "Please enter a valid URL"
        case .validationAlphanumeric:     return "Only letters and numbers are allowed"
        case .validationPasswordStrength: return "Password must be at least 8 characters and include uppercase, lowercase, number, and symbol"
        case .validationCustomDefault:    return "Invalid value"

        // Buttons
        case .buttonCancel:   return "Cancel"
        case .buttonConfirm:  return "Confirm"
        case .buttonDelete:   return "Delete"
        case .buttonSave:     return "Save"
        case .buttonSend:     return "Send"
        case .buttonClose:    return "Close"
        case .buttonRetry:    return "Retry"
        case .buttonDone:     return "Done"
        case .buttonEdit:     return "Edit"
        case .buttonBack:     return "Back"
        case .buttonLoadMore: return "Load more"

        // Search
        case .searchPlaceholder: return "Search"
        case .searchNoResults:   return "No results found"
        case .searchClear:       return "Clear search"

        // States
        case .stateLoading: return "Loading…"
        case .stateEmpty:   return "Nothing here yet"
        case .stateError:   return "Something went wrong"
        case .stateRetry:   return "Try again"

        // File Upload
        case .fileUploadPrompt:    return "Drag & drop a file or"
        case .fileUploadBrowse:    return "Browse"
        case .fileUploadRemoving:  return "Remove"
        case .fileUploadSizeError: return "File exceeds the maximum size (%@)"

        // Date / Time
        case .dateToday:      return "Today"
        case .dateYesterday:  return "Yesterday"
        case .dateJustNow:    return "Just now"
        case .dateMinutesAgo: return "%d minutes ago"

        // Accessibility — General
        case .a11yAvatar:          return "Avatar"
        case .a11yAvatarGroup:     return "%d people"
        case .a11yClose:           return "Close"
        case .a11yBack:            return "Back"
        case .a11yBadgeCount:      return "%d unread"
        case .a11yOnline:          return "Online"
        case .a11yOffline:         return "Offline"
        case .a11yBusy:            return "Busy"
        case .a11yAway:            return "Away"
        case .a11yLoading:         return "Loading"
        case .a11ySelected:        return "selected"
        case .a11yNotSelected:     return "not selected"
        case .a11yDoubleTapRemove: return "Double tap to remove"
        case .a11yClearSearch:     return "Clear search"
        case .a11ySearch:          return "Search"

        // Accessibility — Component Specific
        case .a11yRatingValue:   return "%d out of %d stars"
        case .a11yRatingStars:   return "Rating"
        case .a11yProgress:      return "%d percent"
        case .a11yProgressBar:   return "Progress"
        case .a11ySwitchLabel:   return "Switch"
        case .a11ySwitchOn:      return "On"
        case .a11ySwitchOff:     return "Off"
        case .a11yTimePicker:    return "Time Picker"
        case .a11yDatePicker:    return "Date Picker"
        case .a11yFileUpload:    return "File Upload"
        case .a11yTimeline:      return "Timeline"
        case .a11yBreadcrumb:    return "Breadcrumb navigation"
        case .a11yColorPicker:   return "Color Picker"
        case .a11yReactions:     return "reactions"
        case .a11yTabSelected:   return "Selected"
        case .a11yTabSelectHint: return "Double tap to select"
        case .a11yTabUnread:     return "%d unread"

        // File Upload — UI
        case .fileUploadDrop:      return "Drop files here"
        case .fileUploadTap:       return "Tap to upload a file"
        case .fileUploadFileCount: return "%d file(s) selected"
        case .fileUploadMaxFiles:  return "Maximum %d files allowed"
        case .fileUploadTooLarge:  return "%@ is too large (max: %@)"
        case .fileUploadError:     return "Could not open file: %@"
        case .fileUploadFormats:   return "Supported formats: %@"
        case .fileUploadMaxSize:   return "Maximum file size: %@"

        // Toast
        case .toastInfo:    return "Info"
        case .toastSuccess: return "Success"
        case .toastWarning: return "Warning"
        case .toastError:   return "Error"
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
