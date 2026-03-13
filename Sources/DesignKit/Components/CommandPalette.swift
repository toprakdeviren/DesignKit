import SwiftUI

// MARK: - DKCommand

/// Represents a single actionable item within the Command Palette.
public struct DKCommand: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let systemImage: String?
    public let shortcut: String?
    public let action: () -> Void
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        shortcut: String? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.shortcut = shortcut
        self.action = action
    }
    
    public static func == (lhs: DKCommand, rhs: DKCommand) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - DKCommandPalette

/// A ⌘K style universal search and action palette.
///
/// Features a dimmed background overlay, a text input for filtering,
/// and a list of actionable items. Commonly used for power-user features.
///
/// ```swift
/// .overlay {
///     if isShowingCommandPalette {
///         DKCommandPalette(
///             isPresented: $isShowingCommandPalette,
///             commands: myCommands
///         )
///     }
/// }
/// ```
public struct DKCommandPalette: View {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let commands: [DKCommand]
    
    @State private var searchQuery: String = ""
    @State private var selectedCommandID: String?
    @FocusState private var isSearchFocused: Bool
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Init
    
    /// Initializes a command palette.
    ///
    /// - Parameters:
    ///   - isPresented: Binding to control the visibility of the palette.
    ///   - commands: The list of available commands to filter and execute.
    public init(isPresented: Binding<Bool>, commands: [DKCommand]) {
        self._isPresented = isPresented
        self.commands = commands
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background Dim
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            // Palette Window
            GeometryReader { geo in
                VStack(spacing: 0) {
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.colorTokens.textSecondary)
                        
                        TextField("Search commands...", text: $searchQuery)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(theme.colorTokens.textPrimary)
                            .focused($isSearchFocused)
                            .disableAutocorrection(true)
                            #if os(iOS) || os(tvOS)
                            .textInputAutocapitalization(.never)
                            #endif
                            .submitLabel(.go)
                            .onSubmit {
                                executeSelectedOrFirst()
                            }
                        
                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(theme.colorTokens.textTertiary)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("ESC")
                                .textStyle(.caption2)
                                .foregroundColor(theme.colorTokens.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.colorTokens.border.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                    .padding(DesignTokens.Spacing.md.rawValue)
                    
                    Divider()
                        .background(theme.colorTokens.border.opacity(0.3))
                    
                    // Results List
                    if filteredCommands.isEmpty {
                        emptyState
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(filteredCommands) { command in
                                        commandRow(command)
                                            .id(command.id)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: min(geo.size.height * 0.6, 350))
                            .onChange(of: selectedCommandID) { newID in
                                if let id = newID {
                                    withAnimation {
                                        proxy.scrollTo(id, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                }
                .background(theme.colorTokens.surface)
                .cornerRadius(CGFloat(DesignTokens.Radius.xl.rawValue))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.xl.rawValue))
                        .stroke(theme.colorTokens.border, lineWidth: 1)
                )
                .frame(width: min(geo.size.width - 32, 600))
                .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
            }
        }
        // Fade in animation
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .onAppear {
            isSearchFocused = true
            selectFirstCommand()
        }
        .onChange(of: searchQuery) { _ in
            selectFirstCommand()
        }
        // macOS / iPadOS hardware keyboard navigation
        .onCommand(CommandPaletteActions.moveUp) { moveSelection(up: true) }
        .onCommand(CommandPaletteActions.moveDown) { moveSelection(up: false) }
        .onCommand(CommandPaletteActions.escape) { close() }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(theme.colorTokens.textTertiary)
            Text("No results found")
                .textStyle(.body)
                .foregroundColor(theme.colorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func commandRow(_ command: DKCommand) -> some View {
        let isSelected = (command.id == selectedCommandID)
        
        return Button {
            execute(command)
        } label: {
            HStack(spacing: 12) {
                if let icon = command.systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? theme.colorTokens.primary500 : theme.colorTokens.textSecondary)
                        .frame(width: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(command.title)
                        .textStyle(.body)
                        .foregroundColor(isSelected ? theme.colorTokens.primary500 : theme.colorTokens.textPrimary)
                    
                    if let subtitle = command.subtitle {
                        Text(subtitle)
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                }
                
                Spacer()
                
                if let shortcut = command.shortcut {
                    Text(shortcut)
                        .textStyle(.caption2)
                        .foregroundColor(theme.colorTokens.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.colorTokens.border.opacity(isSelected ? 0.0 : 0.3))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? theme.colorTokens.primary500.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Logic
    
    private var filteredCommands: [DKCommand] {
        if searchQuery.isEmpty { return commands }
        // Simple case-insensitive fuzzy match logic
        let query = searchQuery.lowercased()
        return commands.filter {
            $0.title.lowercased().contains(query) ||
            ($0.subtitle?.lowercased().contains(query) ?? false)
        }
    }
    
    private func selectFirstCommand() {
        selectedCommandID = filteredCommands.first?.id
    }
    
    private func moveSelection(up: Bool) {
        let list = filteredCommands
        guard !list.isEmpty else { return }
        
        let currentIndex = list.firstIndex(where: { $0.id == selectedCommandID }) ?? -1
        
        var newIndex: Int
        if up {
            newIndex = currentIndex - 1
            if newIndex < 0 { newIndex = list.count - 1 }
        } else {
            newIndex = currentIndex + 1
            if newIndex >= list.count { newIndex = 0 }
        }
        
        selectedCommandID = list[newIndex].id
    }
    
    private func executeSelectedOrFirst() {
        let targetID = selectedCommandID ?? filteredCommands.first?.id
        if let cmd = commands.first(where: { $0.id == targetID }) {
            execute(cmd)
        }
    }
    
    private func execute(_ command: DKCommand) {
        command.action()
        close()
    }
    
    private func close() {
        withAnimation {
            isPresented = false
        }
    }
}

// MARK: - Hardware Keyboard Selectors

private struct CommandPaletteActions {
    #if canImport(ObjectiveC)
    static let moveUp = Selector(("moveUp:"))
    static let moveDown = Selector(("moveDown:"))
    static let escape = Selector(("cancelOperation:"))
    #else
    static let moveUp = Selector("moveUp:")
    static let moveDown = Selector("moveDown:")
    static let escape = Selector("cancelOperation:")
    #endif
}

// MARK: - Preview

#if DEBUG
#Preview("Command Palette") {
    struct DemoView: View {
        @State private var isShowing = true
        @State private var lastAction = "None"
        
        let allCommands = [
            DKCommand(title: "Create New Project", subtitle: "Starts a blank workspace", systemImage: "plus.app", shortcut: "⌘ N") { print("New Project") },
            DKCommand(title: "Open File...", systemImage: "folder", shortcut: "⌘ O") { print("Open") },
            DKCommand(title: "Search Documentation", systemImage: "doc.text.magnifyingglass") { print("Docs") },
            DKCommand(title: "Toggle Dark Mode", subtitle: "Switch app appearance", systemImage: "moon.fill", shortcut: "⇧⌘D") { print("Dark Mode") },
            DKCommand(title: "Sign Out", systemImage: "arrow.right.square") { print("Sign out") }
        ]
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Last Action: \(lastAction)")
                        .font(.headline)
                    
                    Button("Show Command Palette (⌘K)") {
                        withAnimation {
                            isShowing = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if isShowing {
                    DKCommandPalette(
                        isPresented: $isShowing,
                        commands: allCommands.map { cmd in
                            DKCommand(id: cmd.id, title: cmd.title, subtitle: cmd.subtitle, systemImage: cmd.systemImage, shortcut: cmd.shortcut) {
                                lastAction = cmd.title
                                isShowing = false
                            }
                        }
                    )
                }
            }
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
