import SwiftUI

/// Theme preview utility for visualizing and testing themes
public struct DKThemePreview: View {
    
    @State private var selectedTheme: ThemeOption = .default
    @State private var selectedCategory: CategoryOption = .colors
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Tema Seçimi") {
                    Picker("Tema", selection: $selectedTheme) {
                        ForEach(ThemeOption.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                Section("Kategori") {
                    ForEach(CategoryOption.allCases) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tema Önizleme")
            .listStyle(.sidebar)
            
            // Preview Area
            ScrollView {
                previewContent
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(currentTheme.colorTokens.background)
        }
        .designKitTheme(currentTheme)
    }
    
    @ViewBuilder
    private var previewContent: some View {
        switch selectedCategory {
        case .colors:
            colorPreview
        case .typography:
            typographyPreview
        case .components:
            componentsPreview
        case .spacing:
            spacingPreview
        case .shadows:
            shadowPreview
        }
    }
    
    // MARK: - Color Preview
    
    private var colorPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Renkler")
                .textStyle(.title2)
            
            colorSection(title: "Primary", colors: [
                ("50", currentTheme.colorTokens.primary50),
                ("100", currentTheme.colorTokens.primary100),
                ("200", currentTheme.colorTokens.primary200),
                ("300", currentTheme.colorTokens.primary300),
                ("400", currentTheme.colorTokens.primary400),
                ("500", currentTheme.colorTokens.primary500),
                ("600", currentTheme.colorTokens.primary600),
                ("700", currentTheme.colorTokens.primary700),
                ("800", currentTheme.colorTokens.primary800),
                ("900", currentTheme.colorTokens.primary900)
            ])
            
            colorSection(title: "Neutral", colors: [
                ("50", currentTheme.colorTokens.neutral50),
                ("100", currentTheme.colorTokens.neutral100),
                ("200", currentTheme.colorTokens.neutral200),
                ("300", currentTheme.colorTokens.neutral300),
                ("400", currentTheme.colorTokens.neutral400),
                ("500", currentTheme.colorTokens.neutral500),
                ("600", currentTheme.colorTokens.neutral600),
                ("700", currentTheme.colorTokens.neutral700),
                ("800", currentTheme.colorTokens.neutral800),
                ("900", currentTheme.colorTokens.neutral900)
            ])
            
            colorSection(title: "Success", colors: [
                ("500", currentTheme.colorTokens.success500),
                ("600", currentTheme.colorTokens.success600),
                ("700", currentTheme.colorTokens.success700)
            ])
            
            colorSection(title: "Warning", colors: [
                ("500", currentTheme.colorTokens.warning500),
                ("600", currentTheme.colorTokens.warning600),
                ("700", currentTheme.colorTokens.warning700)
            ])
            
            colorSection(title: "Danger", colors: [
                ("500", currentTheme.colorTokens.danger500),
                ("600", currentTheme.colorTokens.danger600),
                ("700", currentTheme.colorTokens.danger700)
            ])
            
            colorSection(title: "Semantic", colors: [
                ("Background", currentTheme.colorTokens.background),
                ("Surface", currentTheme.colorTokens.surface),
                ("Border", currentTheme.colorTokens.border),
                ("Text Primary", currentTheme.colorTokens.textPrimary),
                ("Text Secondary", currentTheme.colorTokens.textSecondary),
                ("Text Tertiary", currentTheme.colorTokens.textTertiary)
            ])
        }
    }
    
    private func colorSection(title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .textStyle(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(colors, id: \.0) { name, color in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(currentTheme.colorTokens.border, lineWidth: 1)
                            )
                        
                        Text(name)
                            .textStyle(.caption1)
                            .foregroundColor(currentTheme.colorTokens.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Typography Preview
    
    private var typographyPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Tipografi")
                .textStyle(.title2)
            
            Group {
                Text("Display")
                    .textStyle(.display)
                Text("Title 1")
                    .textStyle(.title1)
                Text("Title 2")
                    .textStyle(.title2)
                Text("Title 3")
                    .textStyle(.title3)
                Text("Headline")
                    .textStyle(.headline)
                Text("Subheadline")
                    .textStyle(.subheadline)
                Text("Body")
                    .textStyle(.body)
                Text("Caption 1")
                    .textStyle(.caption1)
                Text("Caption 2")
                    .textStyle(.caption2)
            }
        }
    }
    
    // MARK: - Components Preview
    
    private var componentsPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Bileşenler")
                .textStyle(.title2)
            
            // Buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Buttons")
                    .textStyle(.headline)
                
                HStack(spacing: 12) {
                    DKButton("Primary", variant: .primary) {}
                    DKButton("Secondary", variant: .secondary) {}
                    DKButton("Link", variant: .link) {}
                }
            }
            
            // Badges
            VStack(alignment: .leading, spacing: 12) {
                Text("Badges")
                    .textStyle(.headline)
                
                HStack(spacing: 12) {
                    DKBadge("Primary", variant: .primary)
                    DKBadge("Success", variant: .success)
                    DKBadge("Warning", variant: .warning)
                    DKBadge("Danger", variant: .danger)
                }
            }
            
            // Avatars
            VStack(alignment: .leading, spacing: 12) {
                Text("Avatars")
                    .textStyle(.headline)
                
                HStack(spacing: 12) {
                    DKAvatar(initials: "AB", size: .sm)
                    DKAvatar(initials: "CD", size: .md, status: .online)
                    DKAvatar(initials: "EF", size: .lg, status: .busy)
                }
            }
            
            // Cards
            VStack(alignment: .leading, spacing: 12) {
                Text("Cards")
                    .textStyle(.headline)
                
                DKCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Title")
                            .textStyle(.headline)
                        Text("Card content goes here.")
                            .textStyle(.body)
                    }
                }
            }
        }
    }
    
    // MARK: - Spacing Preview
    
    private var spacingPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Spacing")
                .textStyle(.title2)
            
            VStack(alignment: .leading, spacing: 16) {
                spacingRow("XS", DesignTokens.Spacing.xs.rawValue)
                spacingRow("SM", DesignTokens.Spacing.sm.rawValue)
                spacingRow("MD", DesignTokens.Spacing.md.rawValue)
                spacingRow("LG", DesignTokens.Spacing.lg.rawValue)
                spacingRow("XL", DesignTokens.Spacing.xl.rawValue)
                spacingRow("XXL", DesignTokens.Spacing.xxl.rawValue)
                spacingRow("XXXL", DesignTokens.Spacing.xxxl.rawValue)
            }
        }
    }
    
    private func spacingRow(_ label: String, _ value: CGFloat) -> some View {
        HStack {
            Text(label)
                .textStyle(.body)
                .frame(width: 60, alignment: .leading)
            
            Rectangle()
                .fill(currentTheme.colorTokens.primary500)
                .frame(width: value, height: 24)
            
            Text("\(Int(value))pt")
                .textStyle(.caption1)
                .foregroundColor(currentTheme.colorTokens.textSecondary)
        }
    }
    
    // MARK: - Shadow Preview
    
    private var shadowPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Shadows")
                .textStyle(.title2)
            
            HStack(spacing: 24) {
                shadowBox("None", .none)
                shadowBox("SM", .sm)
                shadowBox("MD", .md)
                shadowBox("LG", .lg)
            }
        }
    }
    
    private func shadowBox(_ label: String, _ shadow: DesignTokens.Shadow) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .textStyle(.subheadline)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(currentTheme.colorTokens.surface)
                .frame(width: 100, height: 100)
                .shadow(shadow)
        }
    }
    
    // MARK: - Theme Options
    
    enum ThemeOption: String, CaseIterable, Identifiable {
        case `default` = "Default"
        case dark = "Dark"
        case custom = "Custom"
        
        var id: String { rawValue }
    }
    
    enum CategoryOption: String, CaseIterable, Identifiable {
        case colors = "Renkler"
        case typography = "Tipografi"
        case components = "Bileşenler"
        case spacing = "Spacing"
        case shadows = "Shadows"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .colors: return "paintpalette"
            case .typography: return "textformat"
            case .components: return "square.stack.3d.up"
            case .spacing: return "ruler"
            case .shadows: return "shadow"
            }
        }
    }
    
    // MARK: - Current Theme
    
    private var currentTheme: Theme {
        switch selectedTheme {
        case .default:
            return .default
        case .dark:
            return makeDarkTheme()
        case .custom:
            return makeCustomTheme()
        }
    }
    
    private func makeDarkTheme() -> Theme {
        Theme(
            colorTokens: DarkColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
    
    private func makeCustomTheme() -> Theme {
        Theme(
            colorTokens: CustomPreviewColorTokens(),
            designTokens: DefaultDesignTokens(),
            typographyTokens: DefaultTypographyTokens()
        )
    }
}

// MARK: - Dark Theme Colors

struct DarkColorTokens: ColorTokensProvider {
    var neutral50: Color { Color(white: 0.95) }
    var neutral100: Color { Color(white: 0.9) }
    var neutral200: Color { Color(white: 0.8) }
    var neutral300: Color { Color(white: 0.7) }
    var neutral400: Color { Color(white: 0.6) }
    var neutral500: Color { Color(white: 0.5) }
    var neutral600: Color { Color(white: 0.4) }
    var neutral700: Color { Color(white: 0.3) }
    var neutral800: Color { Color(white: 0.2) }
    var neutral900: Color { Color(white: 0.1) }
    var neutral950: Color { Color(white: 0.05) }
    
    var primary50: Color { ColorTokens.primary50 }
    var primary100: Color { ColorTokens.primary100 }
    var primary200: Color { ColorTokens.primary200 }
    var primary300: Color { ColorTokens.primary300 }
    var primary400: Color { ColorTokens.primary400 }
    var primary500: Color { ColorTokens.primary500 }
    var primary600: Color { ColorTokens.primary600 }
    var primary700: Color { ColorTokens.primary700 }
    var primary800: Color { ColorTokens.primary800 }
    var primary900: Color { ColorTokens.primary900 }
    
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { ColorTokens.success500 }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { ColorTokens.warning500 }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { ColorTokens.danger500 }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { ColorTokens.info500 }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
    
    var background: Color { Color(white: 0.1) }
    var surface: Color { Color(white: 0.15) }
    var border: Color { Color(white: 0.3) }
    var textPrimary: Color { Color(white: 0.95) }
    var textSecondary: Color { Color(white: 0.7) }
    var textTertiary: Color { Color(white: 0.5) }
}

// MARK: - Custom Theme Colors

struct CustomPreviewColorTokens: ColorTokensProvider {
    var neutral50: Color { ColorTokens.neutral50 }
    var neutral100: Color { ColorTokens.neutral100 }
    var neutral200: Color { ColorTokens.neutral200 }
    var neutral300: Color { ColorTokens.neutral300 }
    var neutral400: Color { ColorTokens.neutral400 }
    var neutral500: Color { ColorTokens.neutral500 }
    var neutral600: Color { ColorTokens.neutral600 }
    var neutral700: Color { ColorTokens.neutral700 }
    var neutral800: Color { ColorTokens.neutral800 }
    var neutral900: Color { ColorTokens.neutral900 }
    var neutral950: Color { ColorTokens.neutral950 }
    
    // Purple primary
    var primary50: Color { Color(red: 0.96, green: 0.95, blue: 1.0) }
    var primary100: Color { Color(red: 0.93, green: 0.91, blue: 1.0) }
    var primary200: Color { Color(red: 0.87, green: 0.82, blue: 1.0) }
    var primary300: Color { Color(red: 0.78, green: 0.69, blue: 0.99) }
    var primary400: Color { Color(red: 0.67, green: 0.52, blue: 0.98) }
    var primary500: Color { Color(red: 0.58, green: 0.35, blue: 0.96) }
    var primary600: Color { Color(red: 0.51, green: 0.26, blue: 0.88) }
    var primary700: Color { Color(red: 0.44, green: 0.19, blue: 0.78) }
    var primary800: Color { Color(red: 0.37, green: 0.14, blue: 0.66) }
    var primary900: Color { Color(red: 0.30, green: 0.11, blue: 0.54) }
    
    var success50: Color { ColorTokens.success50 }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { ColorTokens.success500 }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }
    
    var warning50: Color { ColorTokens.warning50 }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { ColorTokens.warning500 }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }
    
    var danger50: Color { ColorTokens.danger50 }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { ColorTokens.danger500 }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }
    
    var info50: Color { ColorTokens.info50 }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { ColorTokens.info500 }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }
    
    var background: Color { ColorTokens.background }
    var surface: Color { ColorTokens.surface }
    var border: Color { ColorTokens.border }
    var textPrimary: Color { ColorTokens.textPrimary }
    var textSecondary: Color { ColorTokens.textSecondary }
    var textTertiary: Color { ColorTokens.textTertiary }
}

// MARK: - Preview
#if DEBUG
struct DKThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        DKThemePreview()
    }
}
#endif

