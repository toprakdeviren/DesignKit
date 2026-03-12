import SwiftUI

/// Hazır tema örnekleri
/// DesignKit ile birlikte gelen kullanıma hazır temalar
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension Theme {
    
    /// Oceanic tema - Mavi-yeşil tonları
    static var oceanic: Theme {
        Theme(
            colorTokens: OceanicColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
    
    /// Forest tema - Yeşil doğa tonları
    static var forest: Theme {
        Theme(
            colorTokens: ForestColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
    
    /// Sunset tema - Turuncu-pembe tonları
    static var sunset: Theme {
        Theme(
            colorTokens: SunsetColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
    
    /// Dark tema - Koyu mod
    static var dark: Theme {
        Theme(
            colorTokens: DarkModeColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
    
    /// High Contrast tema - Yüksek kontrast (accessibility)
    static var highContrast: Theme {
        Theme(
            colorTokens: HighContrastColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
}

// MARK: - Oceanic Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct OceanicColorTokens: ColorTokensProvider {
    // Primary - Cyan/Teal
    var primary50: Color { Color(red: 0.92, green: 0.98, blue: 0.99) }
    var primary100: Color { Color(red: 0.80, green: 0.95, blue: 0.98) }
    var primary200: Color { Color(red: 0.65, green: 0.91, blue: 0.96) }
    var primary300: Color { Color(red: 0.45, green: 0.85, blue: 0.94) }
    var primary400: Color { Color(red: 0.27, green: 0.79, blue: 0.91) }
    var primary500: Color { Color(red: 0.09, green: 0.73, blue: 0.88) } // #17BADE
    var primary600: Color { Color(red: 0.08, green: 0.66, blue: 0.79) }
    var primary700: Color { Color(red: 0.07, green: 0.55, blue: 0.67) }
    var primary800: Color { Color(red: 0.06, green: 0.45, blue: 0.55) }
    var primary900: Color { Color(red: 0.04, green: 0.37, blue: 0.45) }
    
    // Neutral - Cool grays
    var neutral50: Color { Color(red: 0.97, green: 0.98, blue: 0.99) }
    var neutral100: Color { Color(red: 0.95, green: 0.96, blue: 0.98) }
    var neutral200: Color { Color(red: 0.91, green: 0.93, blue: 0.96) }
    var neutral300: Color { Color(red: 0.82, green: 0.85, blue: 0.90) }
    var neutral400: Color { Color(red: 0.63, green: 0.67, blue: 0.75) }
    var neutral500: Color { Color(red: 0.44, green: 0.48, blue: 0.56) }
    var neutral600: Color { Color(red: 0.31, green: 0.35, blue: 0.42) }
    var neutral700: Color { Color(red: 0.24, green: 0.28, blue: 0.34) }
    var neutral800: Color { Color(red: 0.15, green: 0.18, blue: 0.23) }
    var neutral900: Color { Color(red: 0.08, green: 0.11, blue: 0.15) }
    var neutral950: Color { Color(red: 0.04, green: 0.06, blue: 0.09) }
    
    // Success, Warning, Danger, Info - Use defaults
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { Color(red: 0.16, green: 0.80, blue: 0.67) }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { Color(red: 0.98, green: 0.75, blue: 0.20) }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { Color(red: 0.96, green: 0.26, blue: 0.38) }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { Color(red: 0.22, green: 0.67, blue: 0.98) }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
    
    // Semantic colors - use defaults
    var background: Color { ColorTokens.background }
    var surface: Color { ColorTokens.surface }
    var border: Color { ColorTokens.border }
    var textPrimary: Color { ColorTokens.textPrimary }
    var textSecondary: Color { ColorTokens.textSecondary }
    var textTertiary: Color { ColorTokens.textTertiary }
    var textOnPrimary: Color { .white }
}

// MARK: - Forest Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct ForestColorTokens: ColorTokensProvider {
    // Primary - Green
    var primary50: Color { Color(red: 0.94, green: 0.98, blue: 0.94) }
    var primary100: Color { Color(red: 0.86, green: 0.95, blue: 0.86) }
    var primary200: Color { Color(red: 0.73, green: 0.90, blue: 0.73) }
    var primary300: Color { Color(red: 0.55, green: 0.83, blue: 0.55) }
    var primary400: Color { Color(red: 0.38, green: 0.75, blue: 0.38) }
    var primary500: Color { Color(red: 0.22, green: 0.66, blue: 0.22) } // #38A838
    var primary600: Color { Color(red: 0.19, green: 0.59, blue: 0.19) }
    var primary700: Color { Color(red: 0.16, green: 0.50, blue: 0.16) }
    var primary800: Color { Color(red: 0.13, green: 0.41, blue: 0.13) }
    var primary900: Color { Color(red: 0.10, green: 0.34, blue: 0.10) }
    
    // Neutral - Warm grays
    var neutral50: Color { Color(red: 0.98, green: 0.98, blue: 0.97) }
    var neutral100: Color { Color(red: 0.96, green: 0.96, blue: 0.94) }
    var neutral200: Color { Color(red: 0.93, green: 0.93, blue: 0.90) }
    var neutral300: Color { Color(red: 0.85, green: 0.85, blue: 0.81) }
    var neutral400: Color { Color(red: 0.67, green: 0.67, blue: 0.62) }
    var neutral500: Color { Color(red: 0.48, green: 0.48, blue: 0.44) }
    var neutral600: Color { Color(red: 0.35, green: 0.35, blue: 0.31) }
    var neutral700: Color { Color(red: 0.28, green: 0.28, blue: 0.24) }
    var neutral800: Color { Color(red: 0.18, green: 0.18, blue: 0.15) }
    var neutral900: Color { Color(red: 0.11, green: 0.11, blue: 0.09) }
    var neutral950: Color { Color(red: 0.06, green: 0.06, blue: 0.04) }
    
    // Success, Warning, Danger, Info - Use defaults with custom 500
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { Color(red: 0.52, green: 0.85, blue: 0.22) }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { Color(red: 0.98, green: 0.81, blue: 0.18) }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { Color(red: 0.95, green: 0.38, blue: 0.22) }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { Color(red: 0.28, green: 0.59, blue: 0.86) }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
    
    // Semantic colors - use defaults
    var background: Color { ColorTokens.background }
    var surface: Color { ColorTokens.surface }
    var border: Color { ColorTokens.border }
    var textPrimary: Color { ColorTokens.textPrimary }
    var textSecondary: Color { ColorTokens.textSecondary }
    var textTertiary: Color { ColorTokens.textTertiary }
    var textOnPrimary: Color { .white }
}

// MARK: - Sunset Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct SunsetColorTokens: ColorTokensProvider {
    // Primary - Orange-Pink
    var primary50: Color { Color(red: 1.0, green: 0.96, blue: 0.94) }
    var primary100: Color { Color(red: 1.0, green: 0.92, blue: 0.88) }
    var primary200: Color { Color(red: 1.0, green: 0.84, blue: 0.76) }
    var primary300: Color { Color(red: 1.0, green: 0.73, blue: 0.61) }
    var primary400: Color { Color(red: 1.0, green: 0.60, blue: 0.45) }
    var primary500: Color { Color(red: 1.0, green: 0.45, blue: 0.28) } // #FF7347
    var primary600: Color { Color(red: 0.90, green: 0.38, blue: 0.22) }
    var primary700: Color { Color(red: 0.76, green: 0.29, blue: 0.17) }
    var primary800: Color { Color(red: 0.62, green: 0.22, blue: 0.13) }
    var primary900: Color { Color(red: 0.51, green: 0.17, blue: 0.10) }
    
    // Neutral - Warm grays
    var neutral50: Color { Color(red: 0.99, green: 0.98, blue: 0.97) }
    var neutral100: Color { Color(red: 0.98, green: 0.96, blue: 0.94) }
    var neutral200: Color { Color(red: 0.96, green: 0.93, blue: 0.90) }
    var neutral300: Color { Color(red: 0.90, green: 0.85, blue: 0.81) }
    var neutral400: Color { Color(red: 0.75, green: 0.67, blue: 0.62) }
    var neutral500: Color { Color(red: 0.56, green: 0.48, blue: 0.44) }
    var neutral600: Color { Color(red: 0.42, green: 0.35, blue: 0.31) }
    var neutral700: Color { Color(red: 0.34, green: 0.28, blue: 0.24) }
    var neutral800: Color { Color(red: 0.23, green: 0.18, blue: 0.15) }
    var neutral900: Color { Color(red: 0.15, green: 0.11, blue: 0.09) }
    var neutral950: Color { Color(red: 0.09, green: 0.06, blue: 0.04) }
    
    // Success, Warning, Danger, Info - Use defaults with custom 500
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { Color(red: 0.40, green: 0.78, blue: 0.35) }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { Color(red: 0.96, green: 0.65, blue: 0.18) }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { Color(red: 0.93, green: 0.24, blue: 0.35) }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { Color(red: 0.67, green: 0.35, blue: 0.93) }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
    
    // Semantic colors - use defaults
    var background: Color { ColorTokens.background }
    var surface: Color { ColorTokens.surface }
    var border: Color { ColorTokens.border }
    var textPrimary: Color { ColorTokens.textPrimary }
    var textSecondary: Color { ColorTokens.textSecondary }
    var textTertiary: Color { ColorTokens.textTertiary }
    var textOnPrimary: Color { .white }
}

// MARK: - Dark Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct DarkModeColorTokens: ColorTokensProvider {
    // Primary - Bright blue (stands out on dark)
    var primary50: Color { Color(red: 0.88, green: 0.93, blue: 1.0) }
    var primary100: Color { Color(red: 0.80, green: 0.89, blue: 1.0) }
    var primary200: Color { Color(red: 0.63, green: 0.80, blue: 1.0) }
    var primary300: Color { Color(red: 0.42, green: 0.69, blue: 1.0) }
    var primary400: Color { Color(red: 0.22, green: 0.58, blue: 1.0) }
    var primary500: Color { Color(red: 0.04, green: 0.48, blue: 0.98) } // #0B7AFA
    var primary600: Color { Color(red: 0.03, green: 0.42, blue: 0.86) }
    var primary700: Color { Color(red: 0.03, green: 0.35, blue: 0.73) }
    var primary800: Color { Color(red: 0.02, green: 0.29, blue: 0.60) }
    var primary900: Color { Color(red: 0.02, green: 0.24, blue: 0.49) }
    
    // Neutral - True dark theme colors (inverted)
    var neutral50: Color { Color(red: 0.07, green: 0.07, blue: 0.07) } // Darkest
    var neutral100: Color { Color(red: 0.11, green: 0.11, blue: 0.11) }
    var neutral200: Color { Color(red: 0.15, green: 0.15, blue: 0.15) }
    var neutral300: Color { Color(red: 0.22, green: 0.22, blue: 0.22) }
    var neutral400: Color { Color(red: 0.33, green: 0.33, blue: 0.33) }
    var neutral500: Color { Color(red: 0.50, green: 0.50, blue: 0.50) }
    var neutral600: Color { Color(red: 0.67, green: 0.67, blue: 0.67) }
    var neutral700: Color { Color(red: 0.78, green: 0.78, blue: 0.78) }
    var neutral800: Color { Color(red: 0.87, green: 0.87, blue: 0.87) }
    var neutral900: Color { Color(red: 0.93, green: 0.93, blue: 0.93) }
    var neutral950: Color { Color(red: 0.98, green: 0.98, blue: 0.98) } // Lightest
    
    // Semantic colors adjusted for dark background
    var background: Color { Color(red: 0.07, green: 0.07, blue: 0.07) }
    var surface: Color { Color(red: 0.11, green: 0.11, blue: 0.11) }
    var border: Color { Color(red: 0.22, green: 0.22, blue: 0.22) }
    var textPrimary: Color { Color(red: 0.98, green: 0.98, blue: 0.98) }
    var textSecondary: Color { Color(red: 0.78, green: 0.78, blue: 0.78) }
    var textTertiary: Color { Color(red: 0.50, green: 0.50, blue: 0.50) }
    var textOnPrimary: Color { .white }
    
    // Success, Warning, Danger, Info - Bright versions for dark bg
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { Color(red: 0.34, green: 0.87, blue: 0.35) }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { Color(red: 0.98, green: 0.75, blue: 0.18) }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { Color(red: 0.96, green: 0.26, blue: 0.27) }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { Color(red: 0.35, green: 0.78, blue: 0.98) }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
}

// MARK: - High Contrast Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct HighContrastColorTokens: ColorTokensProvider {
    // Primary - Strong blue with high contrast
    var primary50: Color { .white }
    var primary100: Color { Color(red: 0.90, green: 0.95, blue: 1.0) }
    var primary200: Color { Color(red: 0.70, green: 0.85, blue: 1.0) }
    var primary300: Color { Color(red: 0.45, green: 0.70, blue: 1.0) }
    var primary400: Color { Color(red: 0.20, green: 0.55, blue: 1.0) }
    var primary500: Color { Color(red: 0.00, green: 0.40, blue: 0.90) } // #0066E6
    var primary600: Color { Color(red: 0.00, green: 0.32, blue: 0.75) }
    var primary700: Color { Color(red: 0.00, green: 0.25, blue: 0.60) }
    var primary800: Color { Color(red: 0.00, green: 0.20, blue: 0.48) }
    var primary900: Color { Color(red: 0.00, green: 0.15, blue: 0.35) }
    
    // Neutral - True black and white for maximum contrast
    var neutral50: Color { .white }
    var neutral100: Color { Color(red: 0.95, green: 0.95, blue: 0.95) }
    var neutral200: Color { Color(red: 0.85, green: 0.85, blue: 0.85) }
    var neutral300: Color { Color(red: 0.70, green: 0.70, blue: 0.70) }
    var neutral400: Color { Color(red: 0.55, green: 0.55, blue: 0.55) }
    var neutral500: Color { Color(red: 0.40, green: 0.40, blue: 0.40) }
    var neutral600: Color { Color(red: 0.30, green: 0.30, blue: 0.30) }
    var neutral700: Color { Color(red: 0.20, green: 0.20, blue: 0.20) }
    var neutral800: Color { Color(red: 0.10, green: 0.10, blue: 0.10) }
    var neutral900: Color { Color(red: 0.05, green: 0.05, blue: 0.05) }
    var neutral950: Color { .black }
    
    // Semantic colors with maximum contrast
    var background: Color { .white }
    var surface: Color { .white }
    var border: Color { .black }
    var textPrimary: Color { .black }
    var textSecondary: Color { Color(red: 0.20, green: 0.20, blue: 0.20) }
    var textTertiary: Color { Color(red: 0.40, green: 0.40, blue: 0.40) }
    var textOnPrimary: Color { .white }
    
    // Success, Warning, Danger, Info - High contrast versions
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { Color(red: 0.00, green: 0.60, blue: 0.00) }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { Color(red: 0.90, green: 0.50, blue: 0.00) }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { Color(red: 0.85, green: 0.00, blue: 0.00) }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { Color(red: 0.00, green: 0.50, blue: 0.75) }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
}

