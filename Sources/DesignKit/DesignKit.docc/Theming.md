# Theming

Define custom themes by implementing the theme protocol system.

## Overview

DesignKit uses a protocol-based theme system that allows you to customize colors, tokens, and typography while maintaining type safety and consistency.

## Default Theme

The default theme is automatically applied:

```swift
ContentView()
    .designKitTheme(.default)
```

## Custom Theme

Define a custom theme by implementing the required protocols:

### Custom Color Tokens

```swift
struct DarkColorTokens: ColorTokensProvider {
    var primary500: Color { Color.purple }
    var background: Color { Color.black }
    var surface: Color { Color(white: 0.1) }
    // ... implement remaining properties
}
```

### Custom Design Tokens

```swift
struct CustomDesignTokens: DesignTokensProvider {
    func spacing(_ spacing: DesignTokens.Spacing) -> CGFloat {
        // Custom spacing values
        spacing.rawValue * 1.5
    }
    
    func radius(_ radius: DesignTokens.Radius) -> CGFloat {
        // Custom radius values
        radius.rawValue * 2
    }
    
    // ... implement remaining methods
}
```

### Apply Custom Theme

```swift
let customTheme = Theme(
    colorTokens: DarkColorTokens(),
    designTokens: CustomDesignTokens(),
    typographyTokens: DefaultTypographyTokens()
)

ContentView()
    .designKitTheme(customTheme)
```

## Accessing Theme in Components

Components automatically use the theme from the environment:

```swift
struct MyComponent: View {
    @Environment(\.designKitTheme) private var theme
    
    var body: some View {
        Text("Hello")
            .foregroundColor(theme.colorTokens.primary500)
    }
}
```

## Best Practices

- **Consistency**: Use tokens instead of hard-coded values
- **Dark Mode**: Ensure sufficient contrast in both light and dark modes
- **Accessibility**: Test with Dynamic Type and VoiceOver
- **Reusability**: Build reusable theme presets for different brands or contexts

