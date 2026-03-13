import SwiftUI

/// Bottom sheet presentation detent
public enum BottomSheetDetent {
    case small
    case medium
    case large
    case custom(CGFloat)
    
    func height(screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .small: return screenHeight * 0.25
        case .medium: return screenHeight * 0.5
        case .large: return screenHeight * 0.9
        case .custom(let height): return min(height, screenHeight * 0.9)
        }
    }
}

/// A bottom sheet component for modal content presentation
public struct DKBottomSheet<Content: View>: View {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let detents: [BottomSheetDetent]
    private let showDragIndicator: Bool
    private let isDismissible: Bool
    private let content: () -> Content
    
    @Environment(\.designKitTheme) private var theme
    @State private var currentDetentIndex: Int = 0
    @State private var offset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    public init(
        isPresented: Binding<Bool>,
        detents: [BottomSheetDetent] = [.medium],
        showDragIndicator: Bool = true,
        isDismissible: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.showDragIndicator = showDragIndicator
        self.isDismissible = isDismissible
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Backdrop
                if isPresented {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if isDismissible {
                                dismiss()
                            }
                        }
                        .transition(.opacity)
                }
                
                // Bottom Sheet
                if isPresented {
                    VStack(spacing: 0) {
                        // Drag Indicator
                        if showDragIndicator {
                            Capsule()
                                .fill(theme.colorTokens.neutral300)
                                .frame(width: 36, height: 5)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                        }
                        
                        // Content
                        content()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: currentHeight(screenHeight: geometry.size.height))
                    .background(theme.colorTokens.background)
                    #if os(iOS) || os(tvOS) || os(visionOS)
                    .customCornerRadius(16, corners: [.topLeft, .topRight])
                    #else
                    .cornerRadius(16)
                    #endif
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                    .offset(y: max(offset + dragOffset, 0))
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                if isDismissible || value.translation.height < 0 {
                                    state = value.translation.height
                                }
                            }
                            .onEnded { value in
                                handleDragEnd(value: value, screenHeight: geometry.size.height)
                            }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(AnimationTokens.appear, value: isPresented)
            .animation(AnimationTokens.appear, value: offset)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Private Helpers
    
    private func currentHeight(screenHeight: CGFloat) -> CGFloat {
        detents[currentDetentIndex].height(screenHeight: screenHeight)
    }
    
    private func handleDragEnd(value: DragGesture.Value, screenHeight: CGFloat) {
        let dragThreshold: CGFloat = 100
        
        if value.translation.height > dragThreshold && isDismissible {
            dismiss()
        } else if value.translation.height < -dragThreshold && currentDetentIndex < detents.count - 1 {
            // Snap to next larger detent
            currentDetentIndex += 1
        } else if value.translation.height > dragThreshold && currentDetentIndex > 0 {
            // Snap to next smaller detent
            currentDetentIndex -= 1
        }
        
        offset = 0
    }
    
    private func dismiss() {
        withAnimation {
            isPresented = false
        }
        offset = 0
        currentDetentIndex = 0
    }
}

// MARK: - Corner Radius Extension
extension View {
    #if os(iOS) || os(tvOS) || os(visionOS)
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    #else
    func customCornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    #endif
}

#if os(iOS) || os(tvOS) || os(visionOS)
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
#else
enum RectCorner: UInt {
    case topLeft = 1
    case topRight = 2
    case bottomLeft = 4
    case bottomRight = 8
    case allCorners = 15
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: RectCorner
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        
        // Top right
        if corners.rawValue & RectCorner.topRight.rawValue != 0 {
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(-90),
                       endAngle: .degrees(0),
                       clockwise: false)
        } else {
            path.addLine(to: topRight)
        }
        
        // Bottom right
        if corners.rawValue & RectCorner.bottomRight.rawValue != 0 {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(0),
                       endAngle: .degrees(90),
                       clockwise: false)
        } else {
            path.addLine(to: bottomRight)
        }
        
        // Bottom left
        if corners.rawValue & RectCorner.bottomLeft.rawValue != 0 {
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                       radius: radius,
                       startAngle: .degrees(90),
                       endAngle: .degrees(180),
                       clockwise: false)
        } else {
            path.addLine(to: bottomLeft)
        }
        
        // Top left
        if corners.rawValue & RectCorner.topLeft.rawValue != 0 {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
        } else {
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        return path
    }
}
#endif

// MARK: - Preview
#if DEBUG
struct DKBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetDemo()
    }
}

struct BottomSheetDemo: View {
    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            VStack {
                DKButton("Bottom Sheet Aç") {
                    showSheet = true
                }
            }
            
            DKBottomSheet(
                isPresented: $showSheet,
                detents: [.medium, .large],
                showDragIndicator: true
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Alt Çekmece")
                        .textStyle(.title3)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<10) { index in
                                HStack {
                                    Image(systemName: "\(index).circle.fill")
                                    Text("Öğe \(index + 1)")
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
#endif

