import SwiftUI
import Combine

// MARK: - DKStoryViewer

/// A premium, Instagram-style story viewer component.
///
/// Features segmented progress bars at the top, automatic advancement,
/// and gesture controls:
/// - Tap left 30% of screen to go back.
/// - Tap right 70% of screen to go forward.
/// - Hold (long press) to pause the timer and hide the UI slightly (premium feel).
///
/// ```swift
/// DKStoryViewer(
///     items: myItems,
///     durationPerItem: 5.0,
///     onComplete: { dismiss() }
/// ) { item in
///     MyStoryContent(item: item)
///        .ignoresSafeArea()
/// }
/// ```
public struct DKStoryViewer<Item: Identifiable, Content: View>: View {
    
    // MARK: - Properties
    
    public let items: [Item]
    public let durationPerItem: TimeInterval
    public let onComplete: () -> Void
    public let content: (Item) -> Content
    
    @Environment(\.designKitTheme) private var theme
    
    // State
    @State private var currentIndex: Int = 0
    @State private var currentProgress: Double = 0.0
    @State private var isPaused: Bool = false
    
    // Timer
    private let timerTick: Double = 0.05 // 50ms ticks for smooth progress
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    /// Initializes the Story Viewer.
    ///
    /// - Parameters:
    ///   - items: The collection of identifiable data items representing each story segment.
    ///   - durationPerItem: How long (in seconds) each story displays before auto-advancing. Default is 5.0.
    ///   - onComplete: Closure triggered when the viewer completes the final story.
    ///   - content: A view builder that constructs the visual representation for a single item.
    public init(
        items: [Item],
        durationPerItem: TimeInterval = 5.0,
        onComplete: @escaping () -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.durationPerItem = max(0.5, durationPerItem)
        self.onComplete = onComplete
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // Background (Deep dark for immersive stories)
                Color.black.ignoresSafeArea()
                
                // Content Layer
                if !items.isEmpty, currentIndex >= 0, currentIndex < items.count {
                    content(items[currentIndex])
                        // Slightly scale down when paused for a premium tactile feel
                        .scaleEffect(isPaused ? 0.98 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isPaused)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Content fills the safe area completely (Stories usually cover standard screen)
                        .ignoresSafeArea()
                }
                
                // Overlay Controls (Taps and Holds)
                touchOverlay(in: geo)
                
                // Segmented Progress Indicators
                if !items.isEmpty {
                    progressIndicators
                        .padding(.horizontal, 8)
                        // In iOS typical story viewers, progress is at the very top of safe area or slightly below
                        .padding(.top, 12)
                        .opacity(isPaused ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isPaused)
                }
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }
    
    // MARK: - Touch Overlay
    
    @ViewBuilder
    private func touchOverlay(in geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left Tap Area (30%)
            Color.white.opacity(0.001)
                .frame(width: geo.size.width * 0.3)
                .onTapGesture {
                    advance(forward: false)
                }
            
            // Right Tap Area (70%)
            Color.white.opacity(0.001)
                .frame(width: geo.size.width * 0.7)
                .onTapGesture {
                    advance(forward: true)
                }
        }
        // Use a DragGesture with minimum distance 0 to detect press and release
        // This is the most reliable way in SwiftUI to do hold-to-pause without intercepting taps wrongly
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPaused = true
                }
                .onEnded { _ in
                    isPaused = false
                }
        )
    }
    
    // MARK: - Progress Indicators
    
    @ViewBuilder
    private var progressIndicators: some View {
        HStack(spacing: 4) {
            ForEach(0..<items.count, id: \.self) { index in
                GeometryReader { proxy in
                    let barWidth = proxy.size.width
                    
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                        
                        // Active track
                        Capsule()
                            .fill(Color.white)
                            .frame(width: activeSegmentWidth(for: index, totalWidth: barWidth))
                    }
                }
                .frame(height: 3)
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    private func activeSegmentWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentIndex {
            // Fully completed segment
            return totalWidth
        } else if index == currentIndex {
            // Partially completed segment
            let fraction = CGFloat(currentProgress / durationPerItem)
            return totalWidth * min(1, max(0, fraction))
        } else {
            // Future segment
            return 0
        }
    }
    
    // MARK: - Logic
    
    private func startTimer() {
        stopTimer()
        let newTimer = Timer.publish(every: timerTick, on: .main, in: .common).autoconnect()
        self.timer = newTimer
        
        self.cancellable = newTimer.sink { _ in
            guard !isPaused else { return }
            
            currentProgress += timerTick
            if currentProgress >= durationPerItem {
                advance(forward: true)
            }
        }
    }
    
    private func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
        timer = nil
    }
    
    private func advance(forward: Bool) {
        if forward {
            if currentIndex < items.count - 1 {
                currentIndex += 1
                currentProgress = 0
            } else {
                // Completed all stories
                stopTimer()
                onComplete()
            }
        } else {
            if currentIndex > 0 {
                // If we are somewhat into the current story, just restart it.
                // If we are at the very beginning, go to previous.
                // Standard Instagram behavior:
                if currentProgress < 0.2 {
                    currentIndex -= 1
                }
                currentProgress = 0
            } else {
                // Already at first story, just reset progress
                currentProgress = 0
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

private struct MockStoryItem: Identifiable {
    let id = UUID()
    let color: Color
    let text: String
}

#Preview("Story Viewer") {
    struct DemoView: View {
        @State private var showStories = true
        
        let storyItems = [
            MockStoryItem(color: .purple, text: "Welcome to Premium UI!"),
            MockStoryItem(color: .orange, text: "Hold the screen to pause."),
            MockStoryItem(color: .teal, text: "Tap left to go back."),
            MockStoryItem(color: .pink, text: "Tap right to skip ahead.")
        ]
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showStories {
                    DKStoryViewer(
                        items: storyItems,
                        durationPerItem: 4.0,
                        onComplete: {
                            withAnimation {
                                showStories = false
                            }
                        }
                    ) { item in
                        ZStack {
                            item.color
                            
                            Text(item.text)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .shadow(radius: 5)
                        }
                    }
                } else {
                    Button("Replay Stories") {
                        withAnimation {
                            showStories = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
