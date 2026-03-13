import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit

// MARK: - DKDocumentPicker (iOS)

/// A wrapper for `UIDocumentPickerViewController` that allows for highly customized
/// file selection logic on iOS devices.
public struct DKDocumentPicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    public let allowedContentTypes: [UTType]
    public let allowsMultipleSelection: Bool
    public let onPick: ([URL]) -> Void
    public let onCancel: () -> Void
    
    // MARK: - Init
    
    public init(
        allowedContentTypes: [UTType] = [.pdf, .image, .text],
        allowsMultipleSelection: Bool = false,
        onPick: @escaping ([URL]) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.allowedContentTypes = allowedContentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onPick = onPick
        self.onCancel = onCancel
    }
    
    // MARK: - UIViewControllerRepresentable
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DKDocumentPicker
        
        init(_ parent: DKDocumentPicker) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPick(urls)
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel()
        }
    }
}
#endif

// MARK: - View Modifier Extension

public extension View {
    
    /// Presents a document picker overlay for selecting files from the device.
    ///
    /// On iOS, this utilizes the native `UIDocumentPickerViewController` wrapped in a sheet.
    /// On macOS and other platforms, this safely falls back to the native `.fileImporter` modifier.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls the presentation of the picker.
    ///   - allowedContentTypes: The UTTypes to filter for (e.g. `.pdf`, `.png`).
    ///   - allowsMultipleSelection: True if the user can select more than one file at once.
    ///   - onPick: Callback triggered with the successfully acquired local `URL`s of the files.
    @ViewBuilder
    func dkDocumentPicker(
        isPresented: Binding<Bool>,
        allowedContentTypes: [UTType] = [.pdf, .image, .text],
        allowsMultipleSelection: Bool = false,
        onPick: @escaping ([URL]) -> Void
    ) -> some View {
        #if os(iOS)
        self.sheet(isPresented: isPresented) {
            DKDocumentPicker(
                allowedContentTypes: allowedContentTypes,
                allowsMultipleSelection: allowsMultipleSelection,
                onPick: { urls in
                    isPresented.wrappedValue = false
                    onPick(urls)
                },
                onCancel: {
                    isPresented.wrappedValue = false
                }
            )
            .ignoresSafeArea()
        }
        #else
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: allowedContentTypes,
            allowsMultipleSelection: allowsMultipleSelection,
            onCompletion: { result in
                switch result {
                case .success(let urls):
                    onPick(urls)
                case .failure:
                    // Automatically dismissed handled by the system
                    break
                }
            }
        )
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Document Picker") {
    struct DemoView: View {
        @State private var showPicker = false
        @State private var pickedFiles = [URL]()
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("File Upload")
                        .font(.title2.bold())
                    
                    Button {
                        showPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Select Documents")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    if !pickedFiles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Files:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(pickedFiles, id: \.self) { url in
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.gray)
                                    Text(url.lastPathComponent)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            // Bind the component logic elegantly through the custom modifier mapper
            .dkDocumentPicker(
                isPresented: $showPicker,
                allowedContentTypes: [.pdf, .plainText, .png, .jpeg],
                allowsMultipleSelection: true,
                onPick: { urls in
                    pickedFiles = urls
                }
            )
        }
    }
    return DemoView()
}
#endif
