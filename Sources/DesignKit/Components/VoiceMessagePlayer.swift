import SwiftUI
import AVFoundation

// MARK: - DKVoiceMessagePlayer

/// A UI component for playing voice messages with a waveform visualizer.
///
/// `DKVoiceMessagePlayer` is a controlled component. It does not handle audio playback
/// inherently but instead provides the UI for playback state, duration, progress,
/// and seeking. You should connect this to your own audio engine or use
/// a simple `AVAudioPlayer` controller.
///
/// ```swift
/// DKVoiceMessagePlayer(
///     isPlaying: isPlaying,
///     progress: progress,
///     duration: 12.5,
///     samples: [0.1, 0.4, 0.8, 0.5, 0.2, 0.9, 0.3, ...],
///     onPlayPause: { isPlaying.toggle() },
///     onSeek: { newProgress in seek(to: newProgress) }
/// )
/// ```
public struct DKVoiceMessagePlayer: View {

    // MARK: - Properties

    /// Whether the audio is currently playing.
    public let isPlaying: Bool

    /// The playback progress from `0.0` to `1.0`.
    public let progress: CGFloat

    /// The total duration of the audio in seconds.
    public let duration: TimeInterval

    /// Normalized audio samples (values between `0.0` and `1.0`) used to draw the waveform.
    public let samples: [CGFloat]

    /// Action called when the play/pause button is tapped.
    public let onPlayPause: () -> Void

    /// Action called when the user drags the waveform to seek.
    public let onSeek: ((CGFloat) -> Void)?

    @Environment(\.designKitTheme) private var theme

    // MARK: - Local State for Seeking

    @State private var dragProgress: CGFloat? = nil

    // MARK: - Init

    public init(
        isPlaying: Bool,
        progress: CGFloat,
        duration: TimeInterval,
        samples: [CGFloat],
        onPlayPause: @escaping () -> Void,
        onSeek: ((CGFloat) -> Void)? = nil
    ) {
        self.isPlaying = isPlaying
        self.progress = max(0, min(1, progress))
        self.duration = max(0, duration)
        self.samples = samples
        self.onPlayPause = onPlayPause
        self.onSeek = onSeek
    }

    // MARK: - Derived

    private var activeProgress: CGFloat {
        dragProgress ?? progress
    }

    private var currentTime: TimeInterval {
        activeProgress * duration
    }

    private var displayTimeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md.rawValue) {
            playPauseButton
            
            VStack(spacing: 4) {
                waveformView
                
                HStack {
                    Text(displayTimeFormatter.string(from: currentTime) ?? "0:00")
                        .textStyle(.caption2)
                        .foregroundColor(theme.colorTokens.primary500)
                        // Make numbers monospaced so the text doesn't explicitly jump around
                        .font(.system(.caption2, design: .monospaced))

                    Spacer()

                    Text(displayTimeFormatter.string(from: duration) ?? "0:00")
                        .textStyle(.caption2)
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
        .padding(.vertical, DesignTokens.Spacing.sm.rawValue)
        .background(theme.colorTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.xl.rawValue)))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.xl.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(String(format: "%.0f%%", activeProgress * 100))
        .accessibilityAction { onPlayPause() }
        .accessibilityAdjustableAction { direction in
            guard let onSeek = onSeek else { return }
            let jump: CGFloat = 0.1
            switch direction {
            case .increment: onSeek(min(1, activeProgress + jump))
            case .decrement: onSeek(max(0, activeProgress - jump))
            @unknown default: break
            }
        }
    }

    // MARK: - Subviews

    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            ZStack {
                Circle()
                    .fill(theme.colorTokens.primary500)
                    .frame(width: 40, height: 40)
                
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    // Visual center offset for play icon
                    .offset(x: isPlaying ? 0 : 1.5, y: 0)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPlaying ? "Pause" : "Play")
    }

    private var waveformView: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 2
            let barWidth: CGFloat = 3
            let totalBars = max(0, Int((geo.size.width + spacing) / (barWidth + spacing)))
            
            HStack(alignment: .center, spacing: spacing) {
                if totalBars > 0 && !samples.isEmpty {
                    let scaledSamples = self.resample(samples: samples, targetCount: totalBars)
                    
                    ForEach(0..<scaledSamples.count, id: \.self) { index in
                        let sample = scaledSamples[index]
                        let normalizedIndex = CGFloat(index) / CGFloat(max(1, scaledSamples.count - 1))
                        let isPlayed = normalizedIndex <= activeProgress
                        
                        Capsule()
                            .fill(
                                isPlayed
                                    ? theme.colorTokens.primary500
                                    : theme.colorTokens.textSecondary.opacity(0.3)
                            )
                            .frame(width: barWidth, height: max(4, sample * geo.size.height))
                            .animation(.linear(duration: 0.1), value: activeProgress)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard onSeek != nil else { return }
                        let p = max(0, min(1, value.location.x / geo.size.width))
                        dragProgress = p
                    }
                    .onEnded { value in
                        guard let seek = onSeek else { return }
                        let p = max(0, min(1, value.location.x / geo.size.width))
                        seek(p)
                        dragProgress = nil
                    }
            )
        }
        .frame(height: 32) // Fixed waveform height
    }

    // MARK: - Helpers

    /// Downsamples or upsamples the waveform data to fit exactly `targetCount` bars.
    private func resample(samples: [CGFloat], targetCount: Int) -> [CGFloat] {
        guard targetCount > 0 else { return [] }
        guard samples.count > 0 else { return Array(repeating: 0.1, count: targetCount) }
        
        var result = [CGFloat]()
        result.reserveCapacity(targetCount)
        
        for i in 0..<targetCount {
            let relativeIndex = CGFloat(i) / CGFloat(max(1, targetCount - 1))
            let sourceIndex = relativeIndex * CGFloat(samples.count - 1)
            
            let lowerIndex = Int(floor(sourceIndex))
            let upperIndex = min(samples.count - 1, Int(ceil(sourceIndex)))
            
            let weight = sourceIndex - CGFloat(lowerIndex)
            
            let lowerVal = max(0, min(1, samples[lowerIndex]))
            let upperVal = max(0, min(1, samples[upperIndex]))
            
            let interpolated = lowerVal * (1 - weight) + upperVal * weight
            result.append(interpolated)
        }
        
        return result
    }

    private var accessibilityLabel: String {
        let playState = isPlaying ? "Playing" : "Paused"
        let fmt = displayTimeFormatter
        let durStr = fmt.string(from: duration) ?? "0"
        let currStr = fmt.string(from: currentTime) ?? "0"
        return "Voice message, \(playState), \(currStr) of \(durStr)"
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Voice Message Player") {
    struct PreviewWrapper: View {
        @State private var isPlaying = false
        @State private var progress: CGFloat = 0.35
        
        // Generate random-ish pleasing waveform data
        let samples: [CGFloat] = {
            var s = [CGFloat]()
            for i in 0..<60 {
                let sinVal = abs(sin(CGFloat(i) * 0.2)) * 0.8
                let noise = CGFloat.random(in: 0.1...0.3)
                s.append(min(1, sinVal + noise))
            }
            return s
        }()

        var body: some View {
            VStack(spacing: 24) {
                DKVoiceMessagePlayer(
                    isPlaying: isPlaying,
                    progress: progress,
                    duration: 34.0,
                    samples: samples,
                    onPlayPause: { isPlaying.toggle() },
                    onSeek: { p in progress = p }
                )

                DKVoiceMessagePlayer(
                    isPlaying: true,
                    progress: 0.8,
                    duration: 120.0,
                    samples: [0.2, 0.4, 0.6, 0.8, 1.0, 0.9, 0.7, 0.5, 0.3, 0.2],
                    onPlayPause: {},
                    onSeek: nil
                )
            }
            .padding()
            .designKitTheme(.default)
        }
    }
    
    return PreviewWrapper()
}
#endif
