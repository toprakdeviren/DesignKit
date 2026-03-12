import SwiftUI

/// Protocol defining theme requirements
public protocol ThemeProtocol {
    var colorTokens: ColorTokensProvider { get }
    var designTokens: DesignTokensProvider { get }
    var typographyTokens: TypographyTokensProvider { get }
}

/// Protocol for color token providers
public protocol ColorTokensProvider {
    // Neutral Scale
    var neutral50: Color { get }
    var neutral100: Color { get }
    var neutral200: Color { get }
    var neutral300: Color { get }
    var neutral400: Color { get }
    var neutral500: Color { get }
    var neutral600: Color { get }
    var neutral700: Color { get }
    var neutral800: Color { get }
    var neutral900: Color { get }
    var neutral950: Color { get }
    
    // Primary Scale
    var primary50: Color { get }
    var primary100: Color { get }
    var primary200: Color { get }
    var primary300: Color { get }
    var primary400: Color { get }
    var primary500: Color { get }
    var primary600: Color { get }
    var primary700: Color { get }
    var primary800: Color { get }
    var primary900: Color { get }
    
    // Success Scale
    var success50: Color { get }
    var success100: Color { get }
    var success200: Color { get }
    var success300: Color { get }
    var success400: Color { get }
    var success500: Color { get }
    var success600: Color { get }
    var success700: Color { get }
    var success800: Color { get }
    var success900: Color { get }
    
    // Warning Scale
    var warning50: Color { get }
    var warning100: Color { get }
    var warning200: Color { get }
    var warning300: Color { get }
    var warning400: Color { get }
    var warning500: Color { get }
    var warning600: Color { get }
    var warning700: Color { get }
    var warning800: Color { get }
    var warning900: Color { get }
    
    // Danger Scale
    var danger50: Color { get }
    var danger100: Color { get }
    var danger200: Color { get }
    var danger300: Color { get }
    var danger400: Color { get }
    var danger500: Color { get }
    var danger600: Color { get }
    var danger700: Color { get }
    var danger800: Color { get }
    var danger900: Color { get }
    
    // Info Scale
    var info50: Color { get }
    var info100: Color { get }
    var info200: Color { get }
    var info300: Color { get }
    var info400: Color { get }
    var info500: Color { get }
    var info600: Color { get }
    var info700: Color { get }
    var info800: Color { get }
    var info900: Color { get }
    
    // Semantic Colors
    var background: Color { get }
    var surface: Color { get }
    var border: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
}

/// Protocol for design token providers
public protocol DesignTokensProvider {
    func spacing(_ spacing: DesignTokens.Spacing) -> CGFloat
    func radius(_ radius: DesignTokens.Radius) -> CGFloat
    func borderWidth(_ width: DesignTokens.BorderWidth) -> CGFloat
    func opacity(_ opacity: DesignTokens.Opacity) -> Double
    func shadow(_ shadow: DesignTokens.Shadow) -> (radius: CGFloat, offset: CGSize, opacity: Double)
}

/// Protocol for typography token providers
public protocol TypographyTokensProvider {
    func textStyle(_ style: TypographyTokens.TextStyle) -> (size: CGFloat, weight: Font.Weight, lineHeight: CGFloat)
}

/// The central theme object for DesignKit
///
/// Access the current theme via `@Environment(\.designKitTheme)` or inject custom themes
/// via SwiftUI environment.
public struct Theme: ThemeProtocol {
    
    // MARK: - Properties
    
    public var colorTokens: ColorTokensProvider
    public var designTokens: DesignTokensProvider
    public var typographyTokens: TypographyTokensProvider
    
    // MARK: - Initialization
    
    public init(
        colorTokens: ColorTokensProvider,
        designTokens: DesignTokensProvider,
        typographyTokens: TypographyTokensProvider
    ) {
        self.colorTokens = colorTokens
        self.designTokens = designTokens
        self.typographyTokens = typographyTokens
    }
    
    // MARK: - Default Theme
    
    /// The default DesignKit theme
    public static let `default` = Theme(
        colorTokens: DefaultColorTokens(),
        designTokens: DefaultDesignTokens(),
        typographyTokens: DefaultTypographyTokens()
    )
}

// MARK: - Default Implementations

/// Default color tokens implementation
public struct DefaultColorTokens: ColorTokensProvider {
    public init() {}
    
    // Neutral Scale
    public var neutral50: Color { ColorTokens.neutral50 }
    public var neutral100: Color { ColorTokens.neutral100 }
    public var neutral200: Color { ColorTokens.neutral200 }
    public var neutral300: Color { ColorTokens.neutral300 }
    public var neutral400: Color { ColorTokens.neutral400 }
    public var neutral500: Color { ColorTokens.neutral500 }
    public var neutral600: Color { ColorTokens.neutral600 }
    public var neutral700: Color { ColorTokens.neutral700 }
    public var neutral800: Color { ColorTokens.neutral800 }
    public var neutral900: Color { ColorTokens.neutral900 }
    public var neutral950: Color { ColorTokens.neutral950 }
    
    // Primary Scale
    public var primary50: Color { ColorTokens.primary50 }
    public var primary100: Color { ColorTokens.primary100 }
    public var primary200: Color { ColorTokens.primary200 }
    public var primary300: Color { ColorTokens.primary300 }
    public var primary400: Color { ColorTokens.primary400 }
    public var primary500: Color { ColorTokens.primary500 }
    public var primary600: Color { ColorTokens.primary600 }
    public var primary700: Color { ColorTokens.primary700 }
    public var primary800: Color { ColorTokens.primary800 }
    public var primary900: Color { ColorTokens.primary900 }
    
    // Success Scale
    public var success50: Color { ColorTokens.success50 }
    public var success100: Color { ColorTokens.success100 }
    public var success200: Color { ColorTokens.success200 }
    public var success300: Color { ColorTokens.success300 }
    public var success400: Color { ColorTokens.success400 }
    public var success500: Color { ColorTokens.success500 }
    public var success600: Color { ColorTokens.success600 }
    public var success700: Color { ColorTokens.success700 }
    public var success800: Color { ColorTokens.success800 }
    public var success900: Color { ColorTokens.success900 }
    
    // Warning Scale
    public var warning50: Color { ColorTokens.warning50 }
    public var warning100: Color { ColorTokens.warning100 }
    public var warning200: Color { ColorTokens.warning200 }
    public var warning300: Color { ColorTokens.warning300 }
    public var warning400: Color { ColorTokens.warning400 }
    public var warning500: Color { ColorTokens.warning500 }
    public var warning600: Color { ColorTokens.warning600 }
    public var warning700: Color { ColorTokens.warning700 }
    public var warning800: Color { ColorTokens.warning800 }
    public var warning900: Color { ColorTokens.warning900 }
    
    // Danger Scale
    public var danger50: Color { ColorTokens.danger50 }
    public var danger100: Color { ColorTokens.danger100 }
    public var danger200: Color { ColorTokens.danger200 }
    public var danger300: Color { ColorTokens.danger300 }
    public var danger400: Color { ColorTokens.danger400 }
    public var danger500: Color { ColorTokens.danger500 }
    public var danger600: Color { ColorTokens.danger600 }
    public var danger700: Color { ColorTokens.danger700 }
    public var danger800: Color { ColorTokens.danger800 }
    public var danger900: Color { ColorTokens.danger900 }
    
    // Info Scale
    public var info50: Color { ColorTokens.info50 }
    public var info100: Color { ColorTokens.info100 }
    public var info200: Color { ColorTokens.info200 }
    public var info300: Color { ColorTokens.info300 }
    public var info400: Color { ColorTokens.info400 }
    public var info500: Color { ColorTokens.info500 }
    public var info600: Color { ColorTokens.info600 }
    public var info700: Color { ColorTokens.info700 }
    public var info800: Color { ColorTokens.info800 }
    public var info900: Color { ColorTokens.info900 }
    
    // Semantic Colors
    public var background: Color { ColorTokens.background }
    public var surface: Color { ColorTokens.surface }
    public var border: Color { ColorTokens.border }
    public var textPrimary: Color { ColorTokens.textPrimary }
    public var textSecondary: Color { ColorTokens.textSecondary }
    public var textTertiary: Color { ColorTokens.textTertiary }
}

/// Default design tokens implementation
public struct DefaultDesignTokens: DesignTokensProvider {
    public init() {}
    
    public func spacing(_ spacing: DesignTokens.Spacing) -> CGFloat {
        spacing.rawValue
    }
    
    public func radius(_ radius: DesignTokens.Radius) -> CGFloat {
        radius.rawValue
    }
    
    public func borderWidth(_ width: DesignTokens.BorderWidth) -> CGFloat {
        width.rawValue
    }
    
    public func opacity(_ opacity: DesignTokens.Opacity) -> Double {
        opacity.rawValue
    }
    
    public func shadow(_ shadow: DesignTokens.Shadow) -> (radius: CGFloat, offset: CGSize, opacity: Double) {
        (shadow.radius, shadow.offset, shadow.opacity)
    }
}

/// Default typography tokens implementation
public struct DefaultTypographyTokens: TypographyTokensProvider {
    public init() {}
    
    public func textStyle(_ style: TypographyTokens.TextStyle) -> (size: CGFloat, weight: Font.Weight, lineHeight: CGFloat) {
        (style.size, style.weight, style.lineHeight)
    }
}

// MARK: - Environment Key

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = .default
}

extension EnvironmentValues {
    /// The current DesignKit theme from environment
    public var designKitTheme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Apply a custom DesignKit theme to the view hierarchy
    ///
    /// - Parameter theme: The theme to apply
    /// - Returns: A view with the custom theme in its environment
    public func designKitTheme(_ theme: Theme) -> some View {
        environment(\.designKitTheme, theme)
    }
}

