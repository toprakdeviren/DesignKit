import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

// MARK: - DKImageCropper

/// A premium interactive image cropper supporting pan, zoom, and rotate via touch gestures.
///
/// Wraps native gestures with a dark cutout overlay providing guides (rule of thirds).
/// Upon cropping, accurately extracts the viewable bounds using UIGraphics context
/// scaling transformations.
///
/// Automatically falls back to a placeholder component on macOS.
///
/// ```swift
/// DKImageCropper(
///     image: myUIImage,
///     cropSize: CGSize(width: 300, height: 300),
///     onCrop: { croppedImage in
///         // use image
///     },
///     onCancel: {
///         // dismiss
///     }
/// )
/// ```
public struct DKImageCropper: View {
    
#if canImport(UIKit)
    public typealias PlatformImage = UIImage
#else
    public typealias PlatformImage = NSImage
#endif

    // MARK: - Properties
    
    public let image: PlatformImage
    public let cropSize: CGSize
    public let onCrop: (PlatformImage) -> Void
    public let onCancel: () -> Void
    
    @Environment(\.designKitTheme) private var theme
    
#if canImport(UIKit)
    // Gesture States
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var angle: Angle = .zero
    @State private var lastAngle: Angle = .zero
#endif

    // MARK: - Init
    
    public init(
        image: PlatformImage,
        cropSize: CGSize = CGSize(width: 300, height: 300),
        onCrop: @escaping (PlatformImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.image = image
        self.cropSize = cropSize
        self.onCrop = onCrop
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    public var body: some View {
#if canImport(UIKit)
        ZStack {
            theme.colorTokens.surface.ignoresSafeArea()
            
            // Image Canvas
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                
                Image(uiImage: image)
                    .resizable()
                    // Map actual pixel size to frame, scaled down natively by view transform
                    // to preserve sharp vector transformations.
                    .frame(width: max(1, image.size.width), height: max(1, image.size.height))
                    .scaleEffect(initialScale * scale)
                    .rotationEffect(angle)
                    .position(center)
                    .offset(offset)
            }
            .contentShape(Rectangle()) // enable gestures across the whole screen
            .gesture(
                DragGesture()
                    .onChanged { val in
                        offset = CGSize(
                            width: lastOffset.width + val.translation.width,
                            height: lastOffset.height + val.translation.height
                        )
                    }
                    .onEnded { _ in lastOffset = offset }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { val in
                        scale = lastScale * val
                    }
                    .onEnded { _ in lastScale = scale }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged { val in
                        angle = lastAngle + val
                    }
                    .onEnded { _ in lastAngle = angle }
            )
            
            // Mask and Guidelines Overlay
            overlayCutout
            
            // Actions
            controlsBar
        }
#else
        ZStack {
            theme.colorTokens.surface.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "crop")
                    .font(.system(size: 48))
                Text("Image Cropper is fully supported on iOS only.")
                    .font(.headline)
            }
            .foregroundColor(theme.colorTokens.textSecondary)
        }
#endif
    }
    
#if canImport(UIKit)
    // MARK: - iOS Components
    
    private var initialScale: CGFloat {
        // Automatically AspectFill the image into the crop frame
        let scX = cropSize.width / max(1, image.size.width)
        let scY = cropSize.height / max(1, image.size.height)
        return max(scX, scY)
    }
    
    @ViewBuilder
    private var overlayCutout: some View {
        ZStack {
            Color.black.opacity(0.6)
                .mask(
                    ZStack {
                        Color.white
                        Rectangle()
                            .frame(width: cropSize.width, height: cropSize.height)
                            .blendMode(.destinationOut)
                    }
                )
            
            // Grid lines overlaying the crop area (Rule of Thirds)
            Rectangle()
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                .frame(width: cropSize.width, height: cropSize.height)
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()
                        Divider().background(Color.white.opacity(0.4))
                        Spacer()
                        Divider().background(Color.white.opacity(0.4))
                        Spacer()
                    }
                )
                .overlay(
                    HStack(spacing: 0) {
                        Spacer()
                        Divider().background(Color.white.opacity(0.4))
                        Spacer()
                        Divider().background(Color.white.opacity(0.4))
                        Spacer()
                    }
                )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    @ViewBuilder
    private var controlsBar: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
                Button {
                    onCrop(renderCrop())
                } label: {
                    Text("Crop")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.colorTokens.primary500)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
            .background(Color.black.opacity(0.85))
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Context Export Math
    
    /// Translates the view's visual transformation metrics exactly down to the raw image bitmap context.
    private func renderCrop() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale // Retain original high-res display mapping
        
        // The context maps to the targeted cutout size
        let renderer = UIGraphicsImageRenderer(size: cropSize, format: format)
        
        return renderer.image { ctx in
            // Shift the drawing pipeline context origin to the center of our cutout
            ctx.cgContext.translateBy(x: cropSize.width / 2, y: cropSize.height / 2)
            
            // Re-apply user's continuous manual offset
            ctx.cgContext.translateBy(x: offset.width, y: offset.height)
            
            // Re-apply cumulative aspect scale and manual zoom
            let combinedScale = initialScale * scale
            ctx.cgContext.scaleBy(x: combinedScale, y: combinedScale)
            
            // Re-apply rotation correctly oriented around the new center coordinate
            ctx.cgContext.rotate(by: CGFloat(angle.radians))
            
            // Finally draw the original UIimage from the relative center out.
            let renderBounds = CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: renderBounds)
        }
    }
#endif
}

// MARK: - Preview

#if DEBUG
#if canImport(UIKit)
#Preview("Image Cropper") {
    struct DemoView: View {
        @State private var croppedImage: UIImage? = nil
        @State private var isShowingCropper = true
        
        private var demoImage: UIImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 600))
            return renderer.image { ctx in
                UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 800, height: 600))
                
                UIColor.white.setFill()
                let text = "TEST IMAGE" as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 64, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
                text.draw(at: CGPoint(x: 180, y: 250), withAttributes: attrs)
            }
        }
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let img = croppedImage {
                        Text("Cropped Result:")
                            .font(.headline)
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .shadow(radius: 5)
                            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                    } else {
                        Text("No crop yet.")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Open Image Cropper") {
                        isShowingCropper = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .fullScreenCover(isPresented: $isShowingCropper) {
                DKImageCropper(
                    image: demoImage,
                    onCrop: { result in
                        croppedImage = result
                        isShowingCropper = false
                    },
                    onCancel: {
                        isShowingCropper = false
                    }
                )
                .designKitTheme(.default)
            }
        }
    }
    return DemoView()
}
#endif
#endif
