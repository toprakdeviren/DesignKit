# Examples

This directory contains a runnable example app that demonstrates how to integrate and use DesignKit components.

## Contents

| File | Description |
|---|---|
| `ExampleApp.swift` | Root `@main` app with theme switcher and tab navigation |
| `ComponentGallery.swift` | Categorized gallery of all components with live previews |

## Running the Example

### Xcode

Open `Package.swift` in Xcode, select the `ExampleApp` scheme, pick an iOS Simulator target, then press `Cmd + R`.

### Command Line

```bash
swift run ExampleApp
```

## Tabs

| Tab | Content |
|---|---|
| Gallery | Categorized list — tap a category for a focused component view |
| Components | Inline overview of core components |
| New | New components added in recent releases |
| Layout | Grid system and spacing scale |
| Tokens | Color, typography, and shadow tokens |

## Theme Switcher

Tap the **Theme** menu in the top-right corner to switch between built-in themes (Default, Oceanic, Forest, Sunset, Dark, High Contrast) and a custom purple theme defined in `ExampleApp.swift`.

## Taking Screenshots

To capture reference images for documentation:

```bash
# Take a screenshot of the booted simulator
xcrun simctl io booted screenshot screenshot.png
```

Or use **Cmd + S** inside Simulator to save to the Desktop.
