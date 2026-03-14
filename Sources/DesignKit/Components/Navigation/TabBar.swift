import SwiftUI

/// Tab bar item configuration
public struct TabBarItem: Identifiable, Equatable {
    public let id: String
    public let icon: String
    public let selectedIcon: String?
    public let label: String
    public let badge: String?

    public init(
        id: String,
        icon: String,
        selectedIcon: String? = nil,
        label: String,
        badge: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.label = label
        self.badge = badge
    }

    public static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// A bottom tab bar component
public struct DKTabBar: View {

    // MARK: - Properties

    private let items: [TabBarItem]
    @Binding private var selectedId: String
    private let onSelect: ((String) -> Void)?

    @Environment(\.designKitTheme) private var theme

    // MARK: - Initialization

    public init(
        items: [TabBarItem],
        selectedId: Binding<String>,
        onSelect: ((String) -> Void)? = nil
    ) {
        self.items = items
        self._selectedId = selectedId
        self.onSelect = onSelect
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs.rawValue) {
            ForEach(items) { item in
                tabButton(for: item)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm.rawValue)
        .padding(.top, DesignTokens.Spacing.sm.rawValue)
        .padding(.bottom, DesignTokens.Spacing.sm.rawValue)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.xl.rawValue)
                .fill(theme.colorTokens.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.xl.rawValue)
                .stroke(theme.colorTokens.border.opacity(0.75), lineWidth: 1)
        )
        .shadow(.md, color: theme.colorTokens.neutral900.opacity(0.18))
        .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
        .padding(.top, DesignTokens.Spacing.xs.rawValue)
    }

    // MARK: - Private Helpers

    private func tabButton(for item: TabBarItem) -> some View {
        let isSelected = item.id == selectedId
        let colors = theme.colorTokens

        return Button(action: {
            withAnimation(AnimationTokens.transition) {
                selectedId = item.id
            }
            onSelect?(item.id)

            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: isSelected ? .light : .soft)
            generator.impactOccurred()
            #endif
        }) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? (item.selectedIcon ?? item.icon) : item.icon)
                        .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? colors.primary600 : colors.textSecondary)

                    if let badge = item.badge {
                        badgeView(badge)
                    }
                }

                Text(item.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? colors.primary600 : colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, DesignTokens.Spacing.sm.rawValue)
            .padding(.vertical, DesignTokens.Spacing.xs.rawValue + 2)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                    .fill(isSelected ? colors.primary50 : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                    .stroke(isSelected ? colors.primary100 : Color.clear, lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.0 : 0.985)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isSelected
            ? DKLocalizer.string(for: .a11yTabSelected)
            : DKLocalizer.string(for: .a11yTabSelectHint))
        .accessibilityValue(item.badge.map { DKLocalizer.string(for: .a11yTabUnread, Int($0) ?? 0) } ?? "")
        .animation(AnimationTokens.micro, value: isSelected)
    }

    private func badgeView(_ badge: String) -> some View {
        Text(badge)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.colorTokens.danger500)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.colorTokens.surface, lineWidth: 1)
            )
            .offset(x: 10, y: -6)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Tab Bar") {
    struct TabBarPreview: View {
        @State private var selectedTab = "home"

        var body: some View {
            VStack {
                Spacer()

                Text("Seçili Tab: \(selectedTab)")
                    .textStyle(.headline)

                Spacer()

                DKTabBar(
                    items: [
                        TabBarItem(id: "home", icon: "house", selectedIcon: "house.fill", label: "Ana Sayfa"),
                        TabBarItem(id: "search", icon: "magnifyingglass", label: "Ara"),
                        TabBarItem(id: "notifications", icon: "bell", selectedIcon: "bell.fill", label: "Bildirimler", badge: "3"),
                        TabBarItem(id: "profile", icon: "person", selectedIcon: "person.fill", label: "Profil")
                    ],
                    selectedId: $selectedTab
                )
            }
        }
    }

    return TabBarPreview()
}
#endif
