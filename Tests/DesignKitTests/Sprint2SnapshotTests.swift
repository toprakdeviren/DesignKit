import XCTest
import SwiftUI
import SnapshotTesting
@testable import DesignKit

// MARK: - Sprint 2 & 3 Snapshot Tests
//
// Visual regression tests for all components added in Sprint 2 (Core Interactions)
// and Sprint 3 (Media & Content).
//
// First run: set `isRecording = true` in setUp() to generate reference images.
// CI runs: leave isRecording = false to compare against stored references.
//
// Run on a fixed device / simulator to avoid resolution differences.
// Recommended: iPhone 15 Pro (390 pt wide)

@MainActor
final class Sprint2SnapshotTests: XCTestCase {

    private let deviceWidth: CGFloat = 390

    // MARK: - DKGrowingTextField

    func test_growingTextField_empty() {
        let view = DKGrowingTextField(text: .constant(""), placeholder: "Type a message…")
            .padding(16)
            .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_growingTextField_singleLine() {
        let view = DKGrowingTextField(text: .constant("Hello, world!"), placeholder: "Type a message…")
            .padding(16)
            .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_growingTextField_multiLine() {
        let long = "This is a longer message that wraps to multiple lines. It keeps growing as the user types more content."
        let view = DKGrowingTextField(text: .constant(long), placeholder: "Type…", maxLines: 5)
            .padding(16)
            .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_growingTextField_withSendButton() {
        let view = DKGrowingTextField(text: .constant("Hey!"), placeholder: "Message…") {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.blue)
        }
        .padding(16)
        .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_growingTextField_withLabel() {
        let view = DKGrowingTextField(text: .constant(""), placeholder: "Add notes…", label: "Notes")
            .padding(16)
            .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - DKSwipeableRow

    func test_swipeableRow_default() {
        let view = DKSwipeableRow(
            trailingActions: [
                DKSwipeAction(icon: "trash", label: "Delete", tint: .red, style: .destructive) {}
            ]
        ) {
            HStack {
                Image(systemName: "envelope")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Message from Alice").font(.headline)
                    Text("Hey, are you free?").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
        }
        .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - DKActivityIndicator

    func test_activityIndicator_typing() {
        let view = DKActivityIndicator(style: .typing)
            .padding(24)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_activityIndicator_processing() {
        let view = DKActivityIndicator(style: .processing)
            .padding(24)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_activityIndicator_pulsing() {
        let view = DKActivityIndicator(style: .pulsing)
            .padding(24)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_activityIndicator_streaming() {
        let view = DKActivityIndicator(style: .streaming)
            .padding(24)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_activityIndicator_withLabel() {
        let view = DKActivityIndicator(style: .typing, label: "Alice is typing…")
            .padding(24)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - DKReactionPicker

    func test_reactionPicker_bar() {
        let items: [DKReactionItem] = [
            DKReactionItem(id: "👍", content: .emoji("👍"), count: 12),
            DKReactionItem(id: "❤️", content: .emoji("❤️"), count: 5, isSelected: true),
            DKReactionItem(id: "😂", content: .emoji("😂"), count: 3),
            DKReactionItem(id: "😮", content: .emoji("😮")),
        ]
        let view = DKReactionPicker(items: .constant(items), style: .bar)
            .padding(16)
            .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_reactionPicker_popup() {
        let items: [DKReactionItem] = [
            DKReactionItem(id: "👍", content: .emoji("👍")),
            DKReactionItem(id: "❤️", content: .emoji("❤️")),
            DKReactionItem(id: "😂", content: .emoji("😂")),
            DKReactionItem(id: "🔥", content: .emoji("🔥")),
            DKReactionItem(id: "👏", content: .emoji("👏")),
        ]
        let view = DKReactionPicker(items: .constant(items), style: .popup)
            .padding(16)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_reactionPicker_inline_withCounts() {
        let items: [DKReactionItem] = [
            DKReactionItem(id: "like",    content: .symbol("hand.thumbsup"), count: 142, isSelected: true),
            DKReactionItem(id: "heart",   content: .symbol("heart"), count: 38),
            DKReactionItem(id: "comment", content: .symbol("bubble.left"), count: 21),
        ]
        let view = DKReactionPicker(items: .constant(items), style: .inline)
            .padding(16)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - DKMediaPreview — Static content (no network)

    func test_mediaPreview_document_card() {
        let view = DKMediaPreview(
            content: .document(
                url: URL(string: "https://example.com/report.pdf")!,
                name: "Q4 Sales Report.pdf",
                mimeType: "application/pdf",
                size: "2.4 MB"
            ),
            style: .card
        )
        .padding(16)
        .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_mediaPreview_link_card() {
        let view = DKMediaPreview(
            content: .link(
                url: URL(string: "https://github.com")!,
                title: "GitHub",
                description: "Where the world builds software.",
                thumbnail: nil
            ),
            style: .card
        )
        .padding(16)
        .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_mediaPreview_audio_card() {
        let view = DKMediaPreview(
            content: .audio(
                url: URL(string: "https://example.com/voice.m4a")!,
                title: "Voice Message",
                duration: 47
            ),
            style: .card
        )
        .padding(16)
        .frame(width: deviceWidth)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_mediaPreview_thumbnails() {
        let view = HStack(spacing: 12) {
            DKMediaPreview(
                content: .document(url: URL(string: "https://x.com")!, name: "File.pdf", mimeType: "application/pdf"),
                style: .thumbnail(size: 64)
            )
            DKMediaPreview(
                content: .audio(url: URL(string: "https://x.com")!, title: "Memo", duration: 12),
                style: .thumbnail(size: 64)
            )
        }
        .padding(16)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - DKViewState / DKStateView

    func test_stateView_loading_list() {
        let view = DKStateView(
            state: DKViewState<[String]>.loading,
            skeletonLayout: .list(rows: 3)
        ) { _ in EmptyView() }
        .frame(width: deviceWidth, height: 200)
        .padding(16)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_stateView_empty() {
        let view = DKStateView(
            state: DKViewState<[String]>.empty(
                message: "No messages yet",
                systemImage: "bubble.left.and.bubble.right"
            )
        ) { _ in EmptyView() }
        .frame(width: deviceWidth, height: 300)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_stateView_error() {
        let view = DKStateView(
            state: DKViewState<[String]>.error(
                DKViewStateError(message: "Connection failed. Please check your internet.", retry: {})
            )
        ) { _ in EmptyView() }
        .frame(width: deviceWidth, height: 300)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - Dark Mode variants for key Sprint 2-3 components

    func test_growingTextField_dark() {
        let view = DKGrowingTextField(text: .constant("Dark mode text"), placeholder: "Type…")
            .preferredColorScheme(.dark)
            .padding(16)
            .frame(width: deviceWidth)
            .background(Color.black)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_reactionPicker_dark() {
        let items: [DKReactionItem] = [
            DKReactionItem(id: "👍", content: .emoji("👍"), count: 12, isSelected: true),
            DKReactionItem(id: "❤️", content: .emoji("❤️"), count: 5),
        ]
        let view = DKReactionPicker(items: .constant(items), style: .bar)
            .preferredColorScheme(.dark)
            .padding(16)
            .background(Color.black)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }
}

// MARK: - SprintSnapshot Setup Shared Helpers

// Helper to render with DesignKit theme applied
private func withTheme<V: View>(_ view: V) -> some View {
    view.environment(\.designKitTheme, DefaultTheme())
}
