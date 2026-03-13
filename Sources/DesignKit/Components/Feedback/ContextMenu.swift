import SwiftUI

// MARK: - Context Menu Item

/// A single item inside a `DKContextMenu`.
public struct DKContextMenuItem: Identifiable {
    public let id: String
    public let icon: String
    public let label: String
    public let role: Role
    public let action: () -> Void

    public enum Role {
        case normal
        case destructive
    }

    public init(
        id: String = UUID().uuidString,
        icon: String,
        label: String,
        role: Role = .normal,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.role = role
        self.action = action
    }
}

// MARK: - Context Menu Separator

/// Groups items in a `DKContextMenu` with an optional title.
public struct DKContextMenuSection {
    public let title: String?
    public let items: [DKContextMenuItem]

    public init(title: String? = nil, items: [DKContextMenuItem]) {
        self.title = title
        self.items = items
    }
}

// MARK: - View Extension

public extension View {

    // MARK: Flat list variant

    /// Attaches a long-press context menu to this view.
    ///
    /// On iOS 16+, uses the native `contextMenu` with a custom `preview`.
    /// Falls back to the system context menu for watch/TV.
    ///
    /// ```swift
    /// MessageBubble(message)
    ///     .dkContextMenu(items: [
    ///         DKContextMenuItem(icon: "arrow.turn.up.left", label: "Reply") { reply(message) },
    ///         DKContextMenuItem(icon: "doc.on.doc", label: "Copy") { UIPasteboard.general.string = message.text },
    ///         DKContextMenuItem(icon: "trash", label: "Delete", role: .destructive) { delete(message) },
    ///     ])
    /// ```
    func dkContextMenu(
        items: [DKContextMenuItem],
        preview: (() -> AnyView)? = nil
    ) -> some View {
        modifier(DKContextMenuModifier(sections: [DKContextMenuSection(items: items)], preview: preview))
    }

    // MARK: Sectioned variant

    /// Attaches a long-press context menu with grouped sections.
    ///
    /// ```swift
    /// view.dkContextMenu(sections: [
    ///     DKContextMenuSection(title: "Actions", items: [editItem, copyItem]),
    ///     DKContextMenuSection(items: [deleteItem]),  // destructive group
    /// ])
    /// ```
    func dkContextMenu(
        sections: [DKContextMenuSection],
        preview: (() -> AnyView)? = nil
    ) -> some View {
        modifier(DKContextMenuModifier(sections: sections, preview: preview))
    }
}

// MARK: - Modifier

private struct DKContextMenuModifier: ViewModifier {
    let sections: [DKContextMenuSection]
    let preview: (() -> AnyView)?

    func body(content: Content) -> some View {
        if let preview {
            content
                .contextMenu(menuItems: { menuContent }, preview: preview)
        } else {
            content
                .contextMenu(menuItems: { menuContent })
        }
    }

    @ViewBuilder
    private var menuContent: some View {
        ForEach(sections.indices, id: \.self) { sectionIdx in
            let section = sections[sectionIdx]
            if let title = section.title {
                Section(title) {
                    sectionItems(section)
                }
            } else {
                sectionItems(section)
            }
        }
    }

    @ViewBuilder
    private func sectionItems(_ section: DKContextMenuSection) -> some View {
        ForEach(section.items) { item in
            Button(role: item.role == .destructive ? .destructive : nil) {
                item.action()
            } label: {
                Label(item.label, systemImage: item.icon)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Context Menu") {
    struct ContextMenuDemo: View {
        @State private var lastAction = "Long-press a card to see the context menu"

        var body: some View {
            VStack(spacing: 24) {
                Text(lastAction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)

                // Message bubble simulation
                HStack {
                    Spacer()
                    Text("Hey, are you free tomorrow?")
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 240)
                        .dkContextMenu(
                            sections: [
                                DKContextMenuSection(items: [
                                    DKContextMenuItem(icon: "arrow.turn.up.left", label: "Reply") {
                                        lastAction = "Tapped: Reply"
                                    },
                                    DKContextMenuItem(icon: "face.smiling", label: "React") {
                                        lastAction = "Tapped: React"
                                    },
                                    DKContextMenuItem(icon: "doc.on.doc", label: "Copy") {
                                        lastAction = "Tapped: Copy"
                                    },
                                    DKContextMenuItem(icon: "arrowshape.turn.up.right", label: "Forward") {
                                        lastAction = "Tapped: Forward"
                                    },
                                ]),
                                DKContextMenuSection(items: [
                                    DKContextMenuItem(icon: "trash", label: "Delete", role: .destructive) {
                                        lastAction = "Tapped: Delete"
                                    }
                                ])
                            ],
                            preview: {
                                AnyView(
                                    Text("Hey, are you free tomorrow?")
                                        .padding(16)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                )
                            }
                        )
                }
                .padding(.horizontal)

                // Generic card
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.adaptiveSecondaryBackground)
                    .frame(height: 100)
                    .overlay(Text("Long-press me").foregroundStyle(.secondary))
                    .padding(.horizontal)
                    .dkContextMenu(items: [
                        DKContextMenuItem(icon: "pencil", label: "Edit") {
                            lastAction = "Tapped: Edit"
                        },
                        DKContextMenuItem(icon: "square.and.arrow.up", label: "Share") {
                            lastAction = "Tapped: Share"
                        },
                        DKContextMenuItem(icon: "star", label: "Favourite") {
                            lastAction = "Tapped: Favourite"
                        },
                        DKContextMenuItem(icon: "trash", label: "Delete", role: .destructive) {
                            lastAction = "Tapped: Delete"
                        }
                    ])
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.adaptiveGroupedBackground)
        }
    }
    return ContextMenuDemo()
}
#endif

// MARK: - Platform Colors

private extension Color {
    static var adaptiveSecondaryBackground: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    static var adaptiveGroupedBackground: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
