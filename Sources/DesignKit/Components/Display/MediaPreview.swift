import SwiftUI

// MARK: - Media Content

/// The type of media content to preview.
public enum DKMediaContent {
    case image(url: URL, aspectRatio: CGFloat? = nil)
    case video(url: URL, thumbnail: URL? = nil, duration: TimeInterval? = nil)
    case audio(url: URL, title: String? = nil, duration: TimeInterval? = nil)
    case document(url: URL, name: String, mimeType: String, size: String? = nil)
    case link(url: URL, title: String? = nil, description: String? = nil, thumbnail: URL? = nil)
    case gif(url: URL)
}

// MARK: - Preview Style

/// How `DKMediaPreview` renders its content.
public enum DKMediaPreviewStyle {
    /// Small inline thumbnail (use inside message bubbles, table cells).
    case thumbnail(size: CGFloat = 64)
    /// Rounded card with metadata (use in feeds, file attachments).
    case card
    /// Full-width hero (use in detail screens, story-style views).
    case hero
}

// MARK: - DKMediaPreview

/// A unified preview card for images, videos, audio, documents, and link previews.
///
/// ```swift
/// // Image card in a feed
/// DKMediaPreview(
///     content: .image(url: post.imageURL),
///     style: .card
/// ) { content in
///     openFullscreen(content)
/// }
///
/// // File attachment thumbnail
/// DKMediaPreview(
///     content: .document(url: file.url, name: file.name, mimeType: file.mime),
///     style: .thumbnail()
/// )
///
/// // Link preview
/// DKMediaPreview(
///     content: .link(url: url, title: "DesignKit", description: "Production-ready SwiftUI library"),
///     style: .card
/// )
/// ```
public struct DKMediaPreview: View {

    // MARK: Properties

    private let content: DKMediaContent
    private let style: DKMediaPreviewStyle
    private let onTap: ((DKMediaContent) -> Void)?

    @Environment(\.designKitTheme) private var theme
    @State private var isPlayingAudio = false

    // MARK: Init

    public init(
        content: DKMediaContent,
        style: DKMediaPreviewStyle = .card,
        onTap: ((DKMediaContent) -> Void)? = nil
    ) {
        self.content = content
        self.style = style
        self.onTap = onTap
    }

    // MARK: Body

    public var body: some View {
        Button {
            onTap?(content)
        } label: {
            contentView
        }
        .buttonStyle(MediaPreviewButtonStyle())
    }

    // MARK: - Content Router

    @ViewBuilder
    private var contentView: some View {
        switch style {
        case .thumbnail(let size): thumbnailView(size: size)
        case .card:                cardView
        case .hero:                heroView
        }
    }

    // MARK: - Thumbnail Style

    @ViewBuilder
    private func thumbnailView(size: CGFloat) -> some View {
        ZStack {
            switch content {
            case .image(let url, _), .gif(let url):
                DKLazyImage(url: url, transition: .fade())
                    .frame(width: size, height: size)
                    .cornerRadius(8)
                    .clipped()

            case .video(_, let thumb, _):
                ZStack {
                    DKLazyImage(url: thumb, placeholder: .color(theme.colorTokens.neutral200))
                        .frame(width: size, height: size)
                        .cornerRadius(8)
                        .clipped()
                    playIcon(size: size * 0.35)
                }

            case .audio(_, let title, _):
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.colorTokens.primary100)
                    .frame(width: size, height: size)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "waveform")
                                .font(.system(size: size * 0.35))
                                .foregroundColor(theme.colorTokens.primary500)
                            if let title {
                                Text(title)
                                    .font(.system(size: 9))
                                    .lineLimit(1)
                                    .foregroundColor(theme.colorTokens.textSecondary)
                            }
                        }
                    )

            case .document(_, let name, let mime, _):
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.colorTokens.neutral100)
                    .frame(width: size, height: size)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: fileIcon(for: mime))
                                .font(.system(size: size * 0.38))
                                .foregroundColor(theme.colorTokens.textSecondary)
                            Text(name)
                                .font(.system(size: 9, weight: .medium))
                                .lineLimit(1)
                                .foregroundColor(theme.colorTokens.textSecondary)
                                .padding(.horizontal, 4)
                        }
                    )

            case .link(_, let title, _, let thumb):
                ZStack {
                    if let thumb {
                        DKLazyImage(url: thumb)
                            .frame(width: size, height: size)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.colorTokens.info100)
                            .frame(width: size, height: size)
                            .overlay(Image(systemName: "link").foregroundColor(theme.colorTokens.info500))
                    }
                    if let title {
                        VStack {
                            Spacer()
                            Text(title)
                                .font(.system(size: 9, weight: .medium))
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .padding(4)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.55))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: size, height: size)
                    }
                }
            }
        }
    }

    // MARK: - Card Style

    @ViewBuilder
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch content {
            case .image(let url, let ratio):
                DKLazyImage(url: url, transition: .fade())
                    .aspectRatio(ratio ?? 16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()

            case .gif(let url):
                DKLazyImage(url: url, transition: .fade())
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        Text("GIF")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.65))
                            .cornerRadius(4)
                            .padding(8)
                    }

            case .video(_, let thumb, let dur):
                ZStack {
                    DKLazyImage(url: thumb, placeholder: .color(theme.colorTokens.neutral200), transition: .fade())
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                    playIcon(size: 48)
                    if let dur {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text(formatDuration(dur))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(6)
                                    .padding(10)
                            }
                        }
                    }
                }

            case .audio(_, let title, let dur):
                audioCardRow(title: title, duration: dur)
                    .padding(14)

            case .document(let url, let name, let mime, let size):
                documentCardRow(url: url, name: name, mime: mime, size: size)
                    .padding(14)

            case .link(let url, let title, let desc, let thumb):
                linkCardView(url: url, title: title, description: desc, thumbnail: thumb)
            }
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.colorTokens.border, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Hero Style

    @ViewBuilder
    private var heroView: some View {
        switch content {
        case .image(let url, _):
            DKLazyImage(url: url, transition: .fade(), contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(Color.black)

        case .video(_, let thumb, _):
            ZStack {
                DKLazyImage(url: thumb, placeholder: .color(.black), transition: .fade())
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
                playIcon(size: 64)
            }

        default:
            cardView
        }
    }

    // MARK: - Sub-views

    private func playIcon(size: CGFloat) -> some View {
        Image(systemName: "play.circle.fill")
            .font(.system(size: size))
            .foregroundStyle(.white, Color.black.opacity(0.4))
            .shadow(color: .black.opacity(0.3), radius: 8)
    }

    private func audioCardRow(title: String?, duration: TimeInterval?) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.colorTokens.primary100)
                    .frame(width: 44, height: 44)
                Image(systemName: isPlayingAudio ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colorTokens.primary500)
            }
            .onTapGesture { isPlayingAudio.toggle() }

            VStack(alignment: .leading, spacing: 4) {
                Text(title ?? "Audio")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.colorTokens.textPrimary)
                    .lineLimit(1)

                if let duration {
                    Text(formatDuration(duration))
                        .font(.system(size: 12))
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }
            Spacer()

            Image(systemName: "waveform")
                .foregroundColor(theme.colorTokens.primary300)
        }
    }

    private func documentCardRow(url: URL, name: String, mime: String, size: String?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.colorTokens.neutral100)
                    .frame(width: 44, height: 44)
                Image(systemName: fileIcon(for: mime))
                    .font(.system(size: 20))
                    .foregroundColor(theme.colorTokens.textSecondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.colorTokens.textPrimary)
                    .lineLimit(1)
                if let size {
                    Text(size)
                        .font(.system(size: 12))
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }
            Spacer()

            Image(systemName: "arrow.down.circle")
                .foregroundColor(theme.colorTokens.primary500)
        }
    }

    private func linkCardView(url: URL, title: String?, description: String?, thumbnail: URL?) -> some View {
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(theme.colorTokens.info500)
                .frame(width: 4)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colorTokens.textPrimary)
                            .lineLimit(2)
                    }
                    if let description {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .lineLimit(2)
                    }
                    Text(url.host ?? url.absoluteString)
                        .font(.system(size: 11))
                        .foregroundColor(theme.colorTokens.info500)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)

                if let thumbnail {
                    DKLazyImage(url: thumbnail, transition: .fade())
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                }
            }
            .padding(12)
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func fileIcon(for mime: String) -> String {
        let m = mime.lowercased()
        if m.contains("pdf")     { return "doc.fill" }
        if m.contains("word")    { return "doc.richtext" }
        if m.contains("sheet") || m.contains("excel") { return "tablecells" }
        if m.contains("zip") || m.contains("archive") { return "archivebox" }
        if m.contains("image")   { return "photo" }
        if m.contains("video")   { return "film" }
        if m.contains("audio")   { return "music.note" }
        return "doc"
    }
}

// MARK: - Button Style

private struct MediaPreviewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AnimationTokens.micro, value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Media Preview") {
    let img = URL(string: "https://picsum.photos/seed/media/800/500")!
    let thumb = URL(string: "https://picsum.photos/seed/thumb/400/250")!

    ScrollView {
        VStack(alignment: .leading, spacing: 28) {
            Text("DKMediaPreview").font(.title2.bold()).padding(.horizontal)

            Group {
                sectionHeader("Image — .card")
                DKMediaPreview(content: .image(url: img), style: .card)

                sectionHeader("Video — .card")
                DKMediaPreview(
                    content: .video(url: URL(string: "https://example.com/v.mp4")!, thumbnail: thumb, duration: 142),
                    style: .card
                )

                sectionHeader("Audio — .card")
                DKMediaPreview(
                    content: .audio(url: URL(string: "https://example.com/a.mp3")!, title: "Voice Message", duration: 48),
                    style: .card
                )

                sectionHeader("Document — .card")
                DKMediaPreview(
                    content: .document(url: URL(string: "https://example.com/f.pdf")!, name: "Q4 Report.pdf", mimeType: "application/pdf", size: "2.4 MB"),
                    style: .card
                )

                sectionHeader("Link — .card")
                DKMediaPreview(
                    content: .link(url: URL(string: "https://github.com")!, title: "GitHub", description: "Where software is built.", thumbnail: thumb),
                    style: .card
                )

                sectionHeader("Thumbnails")
                HStack(spacing: 12) {
                    DKMediaPreview(content: .image(url: img), style: .thumbnail(size: 64))
                    DKMediaPreview(content: .video(url: URL(string: "https://x.com")!, thumbnail: thumb, duration: 30), style: .thumbnail(size: 64))
                    DKMediaPreview(content: .audio(url: URL(string: "https://x.com")!, title: "Memo", duration: 12), style: .thumbnail(size: 64))
                    DKMediaPreview(content: .document(url: URL(string: "https://x.com")!, name: "Report.pdf", mimeType: "application/pdf"), style: .thumbnail(size: 64))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }
}

private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.caption.monospaced())
        .foregroundStyle(.secondary)
}
#endif
