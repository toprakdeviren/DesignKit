import SwiftUI

// MARK: - Core Settings Screen Container

/// A premium, customizable settings screen layout matching iOS standard paradigms.
///
/// Wraps elements in a scrollable, background-aware surface that works identically
/// across platforms, without relying on private `List` styling internals.
///
/// ```swift
/// DKSettingsScreen {
///     DKSettingsGroup(header: "Network", footer: "Configured locally") {
///         DKSettingsNavigationRow(icon: "wifi", title: "Wi-Fi", subtitle: "eduroam") {
///             print("Navigate to WiFi")
///         }
///     }
/// }
/// ```
public struct DKSettingsScreen<Content: View>: View {
    @ViewBuilder public let content: Content
    
    @Environment(\.designKitTheme) private var theme
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                content
            }
            .padding(.vertical, 24)
        }
        .background(theme.colorTokens.background.ignoresSafeArea())
    }
}

// MARK: - Settings Group

/// A distinct group or section within `DKSettingsScreen`.
/// Can optionally contain a string header and footer.
public struct DKSettingsGroup<Content: View>: View {
    public let header: String?
    public let footer: String?
    @ViewBuilder public let content: Content
    
    @Environment(\.designKitTheme) private var theme
    
    public init(header: String? = nil, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let header = header {
                Text(header.uppercased())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .padding(.leading, 16)
                    .padding(.bottom, 2)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(theme.colorTokens.surface)
            .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                    .stroke(theme.colorTokens.border.opacity(0.5), lineWidth: 1)
            )
            
            if let footer = footer {
                Text(footer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(theme.colorTokens.textTertiary)
                    .padding(.leading, 16)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Internal Engine

private struct DKSettingsRowButtonStyle: ButtonStyle {
    let theme: Theme
    let isClickable: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            // Simulate native iOS row touch highlight logic
            .background(isClickable && configuration.isPressed ? theme.colorTokens.border.opacity(0.15) : Color.clear)
    }
}

private struct DKSettingsRowBase<Accessory: View>: View {
    let icon: String?
    let iconBackground: Color?
    let iconForeground: Color
    let title: String
    let titleColor: Color?
    let subtitle: String?
    let showDivider: Bool
    let isClickable: Bool
    let action: (() -> Void)?
    let accessory: Accessory
    
    @Environment(\.designKitTheme) private var theme
    
    var body: some View {
        Button(action: {
            if isClickable { action?() }
        }) {
            HStack(spacing: 16) {
                if let icon = icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(iconBackground ?? theme.colorTokens.primary500)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(iconForeground)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(titleColor ?? theme.colorTokens.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(theme.colorTokens.textTertiary)
                    }
                }
                
                Spacer()
                
                accessory
            }
            .padding(.horizontal, 16)
            .padding(.vertical, subtitle == nil ? 11 : 8)
        }
        .buttonStyle(DKSettingsRowButtonStyle(theme: theme, isClickable: isClickable))
        .disabled(!isClickable)
        .overlay(
            VStack {
                Spacer()
                if showDivider {
                    Divider()
                        .background(theme.colorTokens.border.opacity(0.3))
                        .padding(.leading, icon != nil ? 62 : 16)
                }
            }
        )
    }
}

// MARK: - Row Variants

/// A standard row mapping to an action, featuring an optional right-chevron indicator.
public struct DKSettingsNavigationRow: View {
    public let icon: String?
    public let iconBackground: Color?
    public let title: String
    public let subtitle: String?
    public let showDivider: Bool
    public let action: () -> Void
    
    @Environment(\.designKitTheme) private var theme
    
    public init(
        icon: String? = nil,
        iconBackground: Color? = nil,
        title: String,
        subtitle: String? = nil,
        showDivider: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconBackground = iconBackground
        self.title = title
        self.subtitle = subtitle
        self.showDivider = showDivider
        self.action = action
    }
    
    public var body: some View {
        DKSettingsRowBase(
            icon: icon, iconBackground: iconBackground, iconForeground: .white,
            title: title, titleColor: nil, subtitle: subtitle,
            showDivider: showDivider, isClickable: true, action: action,
            accessory: Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.colorTokens.border) // Use border color as subtle grey placeholder
        )
    }
}

/// A boolean row that manages state via an inline `Toggle`. Native iOS highlight targets map cleanly.
public struct DKSettingsToggleRow: View {
    @Binding public var isOn: Bool
    public let icon: String?
    public let iconBackground: Color?
    public let title: String
    public let subtitle: String?
    public let showDivider: Bool
    
    public init(
        isOn: Binding<Bool>,
        icon: String? = nil,
        iconBackground: Color? = nil,
        title: String,
        subtitle: String? = nil,
        showDivider: Bool = true
    ) {
        self._isOn = isOn
        self.icon = icon
        self.iconBackground = iconBackground
        self.title = title
        self.subtitle = subtitle
        self.showDivider = showDivider
    }
    
    public var body: some View {
        DKSettingsRowBase(
            icon: icon, iconBackground: iconBackground, iconForeground: .white,
            title: title, titleColor: nil, subtitle: subtitle,
            showDivider: showDivider, isClickable: true,
            action: { isOn.toggle() },
            accessory: Toggle("", isOn: $isOn).labelsHidden()
        )
    }
}

/// A readout row primarily indicating a scalar value. Can be made actionable returning an indicator arrow.
public struct DKSettingsValueRow: View {
    public let icon: String?
    public let iconBackground: Color?
    public let title: String
    public let value: String
    public let showDivider: Bool
    public let action: (() -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    public init(
        icon: String? = nil,
        iconBackground: Color? = nil,
        title: String,
        value: String,
        showDivider: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconBackground = iconBackground
        self.title = title
        self.value = value
        self.showDivider = showDivider
        self.action = action
    }
    
    public var body: some View {
        DKSettingsRowBase(
            icon: icon, iconBackground: iconBackground, iconForeground: .white,
            title: title, titleColor: nil, subtitle: nil,
            showDivider: showDivider, isClickable: action != nil, action: action,
            accessory: HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.colorTokens.textSecondary)
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colorTokens.border)
                }
            }
        )
    }
}

/// A row configured purely for critical operations, supporting custom title tinting (e.g. Red destructive flows).
public struct DKSettingsActionRow: View {
    public let icon: String?
    public let iconForeground: Color?
    public let title: String
    public let titleColor: Color?
    public let showDivider: Bool
    public let alignment: HorizontalAlignment
    public let action: () -> Void
    
    public init(
        icon: String? = nil,
        iconForeground: Color? = nil,
        title: String,
        titleColor: Color? = nil,
        showDivider: Bool = true,
        alignment: HorizontalAlignment = .leading,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconForeground = iconForeground
        self.title = title
        self.titleColor = titleColor
        self.showDivider = showDivider
        self.alignment = alignment
        self.action = action
    }
    
    public var body: some View {
        DKSettingsRowBase(
            icon: icon, iconBackground: .clear, iconForeground: iconForeground ?? .red,
            title: title, titleColor: titleColor ?? .red, subtitle: nil,
            showDivider: showDivider, isClickable: true, action: action,
            accessory: EmptyView()
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Settings View") {
    struct DemoView: View {
        @State private var notificationsEnabled = true
        @State private var locationTracking = false
        
        var body: some View {
            DKSettingsScreen {
                DKSettingsGroup(header: "Connectivity", footer: "Manage your active connections.") {
                    DKSettingsValueRow(icon: "wifi", iconBackground: .blue, title: "Wi-Fi", value: "Home Network", action: {})
                    DKSettingsValueRow(icon: "antenna.radiowaves.left.and.right", iconBackground: .green, title: "Cellular", value: "LTE")
                    DKSettingsToggleRow(isOn: .constant(true), icon: "personalhotspot", iconBackground: .green, title: "Personal Hotspot", showDivider: false)
                }
                
                DKSettingsGroup(header: "Preferences") {
                    DKSettingsToggleRow(isOn: $notificationsEnabled, icon: "bell.badge.fill", iconBackground: .red, title: "Notifications")
                    DKSettingsToggleRow(isOn: $locationTracking, icon: "location.fill", iconBackground: .blue, title: "Location Services")
                    DKSettingsNavigationRow(icon: "moon.fill", iconBackground: .indigo, title: "Do Not Disturb", subtitle: "Scheduled from 10 PM", showDivider: false) {
                        print("Nav")
                    }
                }
                
                DKSettingsGroup {
                    DKSettingsActionRow(title: "Log Out", titleColor: .red, showDivider: false) {
                        print("Logging out")
                    }
                }
            }
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
