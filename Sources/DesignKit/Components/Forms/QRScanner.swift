import SwiftUI
#if os(iOS)
import AVFoundation
import UIKit

// MARK: - Error

public enum DKQRScannerError: Error {
    case permissionDenied
    case deviceNotFound
    case setupFailed
}

// MARK: - Internal Representable

private struct QRScannerViewControllerRepresentable: UIViewControllerRepresentable {
    let onResult: (String) -> Void
    let onError: (DKQRScannerError) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult, onError: onError)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let onResult: (String) -> Void
        let onError: (DKQRScannerError) -> Void
        private var hasResult = false
        
        init(onResult: @escaping (String) -> Void, onError: @escaping (DKQRScannerError) -> Void) {
            self.onResult = onResult
            self.onError = onError
        }
        
        func qrScannerDidFindResult(_ result: String) {
            // Prevent multiple rapid fires
            guard !hasResult else { return }
            hasResult = true
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            onResult(result)
            
            // Reset throttle after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hasResult = false
            }
        }
        
        func qrScannerDidFail(with error: DKQRScannerError) {
            onError(error)
        }
    }
}

// MARK: - View Controller

private protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerDidFindResult(_ result: String)
    func qrScannerDidFail(with error: DKQRScannerError)
}

private class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.delegate?.qrScannerDidFail(with: .permissionDenied)
                    }
                }
            }
        default:
            delegate?.qrScannerDidFail(with: .permissionDenied)
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.qrScannerDidFail(with: .deviceNotFound)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.qrScannerDidFail(with: .setupFailed)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.qrScannerDidFail(with: .setupFailed)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            delegate?.qrScannerDidFail(with: .setupFailed)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            delegate?.qrScannerDidFindResult(stringValue)
        }
    }
}
#endif

// MARK: - DKQRScanner Overlay

/// Renders a dynamic targeting frame.
private struct DKQRScannerOverlay: View {
    @Environment(\.designKitTheme) private var theme
    @State private var scanPosition: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geo in
            let frameSize = min(geo.size.width, geo.size.height) * 0.65
            let cornerLength = frameSize * 0.2
            
            ZStack {
                // Dimmed outer region
                Color.black.opacity(0.5)
                    .mask(
                        ZStack {
                            Color.white
                            Rectangle()
                                .frame(width: frameSize, height: frameSize)
                                .blendMode(.destinationOut)
                        }
                    )
                    .allowsHitTesting(false)
                
                // Active Center
                ZStack(alignment: .top) {
                    
                    // The 4 targeting corners
                    Path { path in
                        // Top Left
                        path.move(to: CGPoint(x: 0, y: cornerLength))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: cornerLength, y: 0))
                        
                        // Top Right
                        path.move(to: CGPoint(x: frameSize - cornerLength, y: 0))
                        path.addLine(to: CGPoint(x: frameSize, y: 0))
                        path.addLine(to: CGPoint(x: frameSize, y: cornerLength))
                        
                        // Bottom Right
                        path.move(to: CGPoint(x: frameSize, y: frameSize - cornerLength))
                        path.addLine(to: CGPoint(x: frameSize, y: frameSize))
                        path.addLine(to: CGPoint(x: frameSize - cornerLength, y: frameSize))
                        
                        // Bottom Left
                        path.move(to: CGPoint(x: cornerLength, y: frameSize))
                        path.addLine(to: CGPoint(x: 0, y: frameSize))
                        path.addLine(to: CGPoint(x: 0, y: frameSize - cornerLength))
                    }
                    .stroke(theme.colorTokens.primary500, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    
                    // Animated Scan Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colorTokens.primary500.opacity(0),
                                    theme.colorTokens.primary500.opacity(0.8),
                                    theme.colorTokens.primary500.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .frame(width: frameSize * 0.8)
                        .offset(y: scanPosition)
                        .onAppear {
                            scanPosition = 0
                            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                                scanPosition = frameSize
                            }
                        }
                }
                .frame(width: frameSize, height: frameSize)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - DKQRScanner

/// A premium QR code scanner utilizing native AVFoundation integration.
///
/// Automatically handles camera permissions, session setup, and QR decoding.
/// Displays an animated scanning frame overlay mapped to `designKitTheme` tokens.
///
/// Note: Real scanning hardware features are only fully compiled/supported on iOS.
/// On macOS, this renders a simulated placeholder overlay.
///
/// ```swift
/// DKQRScanner(
///     onResult: { code in print("Scanned: \(code)") },
///     onError: { error in print("Failed: \(error)") }
/// )
/// .ignoresSafeArea()
/// ```
public struct DKQRScanner: View {
    
    // MARK: - Properties
    
    public let onResult: (String) -> Void
    public let onError: ((Error) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Init
    
    public init(onResult: @escaping (String) -> Void, onError: ((Error) -> Void)? = nil) {
        self.onResult = onResult
        self.onError = onError
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            #if os(iOS)
            QRScannerViewControllerRepresentable(
                onResult: onResult,
                onError: { error in
                    onError?(error)
                }
            )
            .ignoresSafeArea()
            #else
            // Fallback for macOS
            ZStack {
                theme.colorTokens.surface
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48))
                    Text("QR Scanner is only available on iOS.")
                        .textStyle(.headline)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(theme.colorTokens.textSecondary)
                .padding()
            }
            .ignoresSafeArea()
            #endif
            
            // Custom targeting UI Overlay
            DKQRScannerOverlay()
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("QR Scanner") {
    struct DemoView: View {
        @State private var lastScanned: String = "None"
        
        var body: some View {
            ZStack {
                DKQRScanner { result in
                    lastScanned = result
                } onError: { _ in
                    // handle error secretly in preview
                }
                
                VStack {
                    Spacer()
                    
                    Text("Scanned: \(lastScanned)")
                        .textStyle(.caption1)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                }
            }
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
