import Foundation
import SwiftUI

/// Token exporter for design tokens (JSON, Figma, Sketch formats)
public struct TokenExporter {
    
    public enum ExportFormat {
        case json
        case figma
        case sketch
        case css
        case tailwind
    }
    
    public enum ExportOptions {
        case colors
        case typography
        case spacing
        case shadows
        case all
    }
    
    // MARK: - Export Methods
    
    /// Export tokens in specified format
    public static func export(
        theme: Theme,
        format: ExportFormat,
        options: ExportOptions = .all
    ) throws -> String {
        switch format {
        case .json:
            return try exportJSON(theme: theme, options: options)
        case .figma:
            return try exportFigma(theme: theme, options: options)
        case .sketch:
            return try exportSketch(theme: theme, options: options)
        case .css:
            return try exportCSS(theme: theme, options: options)
        case .tailwind:
            return try exportTailwind(theme: theme, options: options)
        }
    }
    
    // MARK: - JSON Export
    
    private static func exportJSON(theme: Theme, options: ExportOptions) throws -> String {
        var tokens: [String: Any] = [:]
        
        if options == .all || options == .colors {
            tokens["colors"] = exportColorsJSON(theme: theme)
        }
        
        if options == .all || options == .typography {
            tokens["typography"] = exportTypographyJSON(theme: theme)
        }
        
        if options == .all || options == .spacing {
            tokens["spacing"] = exportSpacingJSON()
        }
        
        if options == .all || options == .shadows {
            tokens["shadows"] = exportShadowsJSON()
        }
        
        let data = try JSONSerialization.data(withJSONObject: tokens, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private static func exportColorsJSON(theme: Theme) -> [String: Any] {
        let colors = theme.colorTokens
        
        return [
            "primary": [
                "50": colorToHex(colors.primary50),
                "100": colorToHex(colors.primary100),
                "200": colorToHex(colors.primary200),
                "300": colorToHex(colors.primary300),
                "400": colorToHex(colors.primary400),
                "500": colorToHex(colors.primary500),
                "600": colorToHex(colors.primary600),
                "700": colorToHex(colors.primary700),
                "800": colorToHex(colors.primary800),
                "900": colorToHex(colors.primary900)
            ],
            "neutral": [
                "50": colorToHex(colors.neutral50),
                "100": colorToHex(colors.neutral100),
                "200": colorToHex(colors.neutral200),
                "300": colorToHex(colors.neutral300),
                "400": colorToHex(colors.neutral400),
                "500": colorToHex(colors.neutral500),
                "600": colorToHex(colors.neutral600),
                "700": colorToHex(colors.neutral700),
                "800": colorToHex(colors.neutral800),
                "900": colorToHex(colors.neutral900),
                "950": colorToHex(colors.neutral950)
            ],
            "success": [
                "500": colorToHex(colors.success500),
                "600": colorToHex(colors.success600),
                "700": colorToHex(colors.success700)
            ],
            "warning": [
                "500": colorToHex(colors.warning500),
                "600": colorToHex(colors.warning600),
                "700": colorToHex(colors.warning700)
            ],
            "danger": [
                "500": colorToHex(colors.danger500),
                "600": colorToHex(colors.danger600),
                "700": colorToHex(colors.danger700)
            ],
            "semantic": [
                "background": colorToHex(colors.background),
                "surface": colorToHex(colors.surface),
                "border": colorToHex(colors.border),
                "textPrimary": colorToHex(colors.textPrimary),
                "textSecondary": colorToHex(colors.textSecondary),
                "textTertiary": colorToHex(colors.textTertiary)
            ]
        ]
    }
    
    private static func exportTypographyJSON(theme: Theme) -> [String: Any] {
        return [
            "display": typographyStyleToJSON(.display),
            "title1": typographyStyleToJSON(.title1),
            "title2": typographyStyleToJSON(.title2),
            "title3": typographyStyleToJSON(.title3),
            "headline": typographyStyleToJSON(.headline),
            "subheadline": typographyStyleToJSON(.subheadline),
            "body": typographyStyleToJSON(.body),
            "caption1": typographyStyleToJSON(.caption1),
            "caption2": typographyStyleToJSON(.caption2)
        ]
    }
    
    private static func typographyStyleToJSON(_ style: TypographyTokens.TextStyle) -> [String: Any] {
        return [
            "fontSize": style.size,
            "fontWeight": fontWeightToString(style.weight),
            "lineHeight": style.lineHeight
        ]
    }
    
    private static func exportSpacingJSON() -> [String: Any] {
        return [
            "xs": DesignTokens.Spacing.xs.rawValue,
            "sm": DesignTokens.Spacing.sm.rawValue,
            "md": DesignTokens.Spacing.md.rawValue,
            "lg": DesignTokens.Spacing.lg.rawValue,
            "xl": DesignTokens.Spacing.xl.rawValue,
            "xxl": DesignTokens.Spacing.xxl.rawValue,
            "xxxl": DesignTokens.Spacing.xxxl.rawValue
        ]
    }
    
    private static func exportShadowsJSON() -> [String: Any] {
        return [
            "none": shadowToJSON(.none),
            "sm": shadowToJSON(.sm),
            "md": shadowToJSON(.md),
            "lg": shadowToJSON(.lg)
        ]
    }
    
    private static func shadowToJSON(_ shadow: DesignTokens.Shadow) -> [String: Any] {
        return [
            "radius": shadow.radius,
            "offsetX": shadow.offset.width,
            "offsetY": shadow.offset.height,
            "opacity": shadow.opacity
        ]
    }
    
    // MARK: - Figma Export
    
    private static func exportFigma(theme: Theme, options: ExportOptions) throws -> String {
        var figmaTokens: [String: Any] = [:]
        
        if options == .all || options == .colors {
            figmaTokens = exportColorsFigma(theme: theme)
        }
        
        let data = try JSONSerialization.data(withJSONObject: figmaTokens, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private static func exportColorsFigma(theme: Theme) -> [String: Any] {
        let colors = theme.colorTokens
        
        func colorToFigma(_ color: Color, name: String) -> [String: Any] {
            let components = colorToRGBA(color)
            return [
                "name": name,
                "type": "COLOR",
                "value": [
                    "r": components.r,
                    "g": components.g,
                    "b": components.b,
                    "a": components.a
                ]
            ]
        }
        
        var figmaColors: [[String: Any]] = []
        
        // Primary colors
        figmaColors.append(colorToFigma(colors.primary500, name: "Primary/500"))
        figmaColors.append(colorToFigma(colors.primary600, name: "Primary/600"))
        figmaColors.append(colorToFigma(colors.primary700, name: "Primary/700"))
        
        // Semantic colors
        figmaColors.append(colorToFigma(colors.background, name: "Semantic/Background"))
        figmaColors.append(colorToFigma(colors.surface, name: "Semantic/Surface"))
        figmaColors.append(colorToFigma(colors.textPrimary, name: "Semantic/Text Primary"))
        
        return ["colors": figmaColors]
    }
    
    // MARK: - CSS Export
    
    private static func exportCSS(theme: Theme, options: ExportOptions) throws -> String {
        var css = ":root {\n"
        
        if options == .all || options == .colors {
            css += exportColorsCSS(theme: theme)
        }
        
        if options == .all || options == .spacing {
            css += exportSpacingCSS()
        }
        
        css += "}\n"
        return css
    }
    
    private static func exportColorsCSS(theme: Theme) -> String {
        let colors = theme.colorTokens
        var css = ""
        
        css += "  /* Primary Colors */\n"
        css += "  --primary-500: \(colorToHex(colors.primary500));\n"
        css += "  --primary-600: \(colorToHex(colors.primary600));\n"
        css += "  --primary-700: \(colorToHex(colors.primary700));\n\n"
        
        css += "  /* Semantic Colors */\n"
        css += "  --background: \(colorToHex(colors.background));\n"
        css += "  --surface: \(colorToHex(colors.surface));\n"
        css += "  --border: \(colorToHex(colors.border));\n"
        css += "  --text-primary: \(colorToHex(colors.textPrimary));\n"
        css += "  --text-secondary: \(colorToHex(colors.textSecondary));\n\n"
        
        return css
    }
    
    private static func exportSpacingCSS() -> String {
        var css = "  /* Spacing */\n"
        css += "  --spacing-xs: \(DesignTokens.Spacing.xs.rawValue)px;\n"
        css += "  --spacing-sm: \(DesignTokens.Spacing.sm.rawValue)px;\n"
        css += "  --spacing-md: \(DesignTokens.Spacing.md.rawValue)px;\n"
        css += "  --spacing-lg: \(DesignTokens.Spacing.lg.rawValue)px;\n"
        css += "  --spacing-xl: \(DesignTokens.Spacing.xl.rawValue)px;\n\n"
        return css
    }
    
    // MARK: - Tailwind Export
    
    private static func exportTailwind(theme: Theme, options: ExportOptions) throws -> String {
        var config = "module.exports = {\n"
        config += "  theme: {\n"
        config += "    extend: {\n"
        
        if options == .all || options == .colors {
            config += exportColorsTailwind(theme: theme)
        }
        
        if options == .all || options == .spacing {
            config += exportSpacingTailwind()
        }
        
        config += "    }\n"
        config += "  }\n"
        config += "}\n"
        
        return config
    }
    
    private static func exportColorsTailwind(theme: Theme) -> String {
        let colors = theme.colorTokens
        var config = "      colors: {\n"
        
        config += "        primary: {\n"
        config += "          500: '\(colorToHex(colors.primary500))',\n"
        config += "          600: '\(colorToHex(colors.primary600))',\n"
        config += "          700: '\(colorToHex(colors.primary700))',\n"
        config += "        },\n"
        
        config += "      },\n"
        return config
    }
    
    private static func exportSpacingTailwind() -> String {
        var config = "      spacing: {\n"
        config += "        'xs': '\(DesignTokens.Spacing.xs.rawValue)px',\n"
        config += "        'sm': '\(DesignTokens.Spacing.sm.rawValue)px',\n"
        config += "        'md': '\(DesignTokens.Spacing.md.rawValue)px',\n"
        config += "        'lg': '\(DesignTokens.Spacing.lg.rawValue)px',\n"
        config += "      },\n"
        return config
    }
    
    // MARK: - Sketch Export (similar to Figma)
    
    private static func exportSketch(theme: Theme, options: ExportOptions) throws -> String {
        // Sketch format is similar to Figma
        return try exportFigma(theme: theme, options: options)
    }
    
    // MARK: - Helper Methods
    
    private static func colorToHex(_ color: Color) -> String {
        let components = colorToRGBA(color)
        let r = Int(components.r * 255)
        let g = Int(components.g * 255)
        let b = Int(components.b * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    private static func colorToRGBA(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        #if os(iOS)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
        #elseif os(macOS)
        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return (0, 0, 0, 1)
        }
        return (Double(rgbColor.redComponent), Double(rgbColor.greenComponent), Double(rgbColor.blueComponent), Double(rgbColor.alphaComponent))
        #else
        return (0.5, 0.5, 0.5, 1.0)
        #endif
    }
    
    private static func fontWeightToString(_ weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight: return "100"
        case .thin: return "200"
        case .light: return "300"
        case .regular: return "400"
        case .medium: return "500"
        case .semibold: return "600"
        case .bold: return "700"
        case .heavy: return "800"
        case .black: return "900"
        default: return "400"
        }
    }
}

// MARK: - Export to File

extension TokenExporter {
    /// Export tokens to a file
    public static func exportToFile(
        theme: Theme,
        format: ExportFormat,
        options: ExportOptions = .all,
        outputPath: String
    ) throws {
        let content = try export(theme: theme, format: format, options: options)
        let url = URL(fileURLWithPath: outputPath)
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// Generate filename based on format
    public static func defaultFileName(for format: ExportFormat) -> String {
        switch format {
        case .json:
            return "design-tokens.json"
        case .figma:
            return "figma-tokens.json"
        case .sketch:
            return "sketch-tokens.json"
        case .css:
            return "tokens.css"
        case .tailwind:
            return "tailwind.config.js"
        }
    }
}

// MARK: - CLI Usage Example

public struct TokenExporterCLI {
    public static func main() {
        print("🎨 DesignKit Token Exporter\n")
        
        let theme = Theme.default
        
        do {
            // Export JSON
            let json = try TokenExporter.export(theme: theme, format: .json, options: .all)
            print("📄 JSON Export:")
            print(json)
            print()
            
            // Export CSS
            let css = try TokenExporter.export(theme: theme, format: .css, options: .all)
            print("🎨 CSS Export:")
            print(css)
            print()
            
            print("✅ Export tamamlandı!")
        } catch {
            print("❌ Hata: \(error)")
        }
    }
}

