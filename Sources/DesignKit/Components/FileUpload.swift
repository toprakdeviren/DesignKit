import SwiftUI
import UniformTypeIdentifiers

/// File upload component with drag & drop support
public struct DKFileUpload: View {
    
    // MARK: - File Info
    
    public struct FileInfo: Identifiable {
        public let id: UUID
        public let name: String
        public let size: Int64
        public let type: String
        public let url: URL?
        
        public init(id: UUID = UUID(), name: String, size: Int64, type: String, url: URL? = nil) {
            self.id = id
            self.name = name
            self.size = size
            self.type = type
            self.url = url
        }
        
        public var formattedSize: String {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: size)
        }
    }
    
    // MARK: - Properties
    
    private let label: String?
    private let acceptedTypes: [UTType]
    private let maxFileSize: Int64?
    private let maxFiles: Int?
    private let isMultiple: Bool
    private let showPreview: Bool
    @Binding private var files: [FileInfo]
    private let onFilesSelected: (([FileInfo]) -> Void)?
    private let isDisabled: Bool
    
    @Environment(\.designKitTheme) private var theme
    @State private var isDragging: Bool = false
    @State private var showingFilePicker: Bool = false
    @State private var errorMessage: String?
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        files: Binding<[FileInfo]>,
        acceptedTypes: [UTType] = [.data],
        maxFileSize: Int64? = nil,
        maxFiles: Int? = nil,
        isMultiple: Bool = true,
        showPreview: Bool = true,
        isDisabled: Bool = false,
        onFilesSelected: (([FileInfo]) -> Void)? = nil
    ) {
        self.label = label
        self._files = files
        self.acceptedTypes = acceptedTypes
        self.maxFileSize = maxFileSize
        self.maxFiles = maxFiles
        self.isMultiple = isMultiple
        self.showPreview = showPreview
        self.isDisabled = isDisabled
        self.onFilesSelected = onFilesSelected
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            // Drop Zone
            dropZone
            
            // Error Message
            if let errorMessage = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(theme.colorTokens.danger500)
                    Text(errorMessage)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.danger500)
                }
            }
            
            // File List
            if showPreview && !files.isEmpty {
                VStack(spacing: 8) {
                    ForEach(files) { file in
                        fileRow(file)
                    }
                }
            }
            
            // Helper Text
            if !files.isEmpty {
                Text(DKLocalizer.string(for: .fileUploadFileCount, files.count))
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label ?? DKLocalizer.string(for: .a11yFileUpload))
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: acceptedTypes,
            allowsMultipleSelection: isMultiple
        ) { result in
            handleFileSelection(result)
        }
    }
    
    // MARK: - Drop Zone
    
    private var dropZone: some View {
        Button(action: {
            if !isDisabled {
                showingFilePicker = true
            }
        }) {
            VStack(spacing: 16) {
                Image(systemName: isDragging ? "arrow.down.doc.fill" : "arrow.up.doc.fill")
                    .font(.system(size: 48))
                    .foregroundColor(isDragging ? theme.colorTokens.primary500 : theme.colorTokens.textSecondary)
                
                VStack(spacing: 4) {
                    Text(isDragging
                         ? DKLocalizer.string(for: .fileUploadDrop)
                         : DKLocalizer.string(for: .fileUploadTap))
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textPrimary)
                    
                    if !acceptedTypes.isEmpty {
                        Text(DKLocalizer.string(for: .fileUploadFormats, acceptedTypesDescription))
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                    
                    if let maxFileSize = maxFileSize {
                        Text(DKLocalizer.string(for: .fileUploadMaxSize, formatBytes(maxFileSize)))
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                    .strokeBorder(
                        isDragging ? theme.colorTokens.primary500 : theme.colorTokens.border,
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                            .fill(isDragging ? theme.colorTokens.primary50.opacity(0.3) : theme.colorTokens.surface.opacity(0.5))
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onDrop(of: acceptedTypes, isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    // MARK: - File Row
    
    private func fileRow(_ file: FileInfo) -> some View {
        HStack(spacing: 12) {
            // File Icon
            Image(systemName: fileIcon(for: file.type))
                .font(.system(size: 24))
                .foregroundColor(theme.colorTokens.primary500)
                .frame(width: 40, height: 40)
                .background(theme.colorTokens.primary50)
                .cornerRadius(DesignTokens.Radius.sm.rawValue)
            
            // File Info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .textStyle(.body)
                    .foregroundColor(theme.colorTokens.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(file.formattedSize)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    Text(file.type)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }
            
            Spacer()
            
            // Remove Button
            Button(action: {
                removeFile(file)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(theme.colorTokens.danger500)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(theme.colorTokens.surface)
        .cornerRadius(DesignTokens.Radius.md.rawValue)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
    }
    
    // MARK: - File Handling
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        errorMessage = nil
        
        switch result {
        case .success(let urls):
            processFiles(urls)
        case .failure(let error):
            errorMessage = DKLocalizer.string(for: .fileUploadError, error.localizedDescription)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        errorMessage = nil
        
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            processFiles([url])
                        }
                    }
                }
            }
        }
    }
    
    private func processFiles(_ urls: [URL]) {
        var newFiles: [FileInfo] = []
        
        for url in urls {
            // Check max files limit
            if let maxFiles = maxFiles, files.count + newFiles.count >= maxFiles {
                errorMessage = DKLocalizer.string(for: .fileUploadMaxFiles, maxFiles)
                break
            }
            
            // Get file attributes
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let fileSize = attributes[.size] as? Int64 else {
                continue
            }
            
            // Check file size
            if let maxFileSize = maxFileSize, fileSize > maxFileSize {
                errorMessage = DKLocalizer.string(for: .fileUploadTooLarge, url.lastPathComponent, formatBytes(maxFileSize))
                continue
            }
            
            let fileInfo = FileInfo(
                name: url.lastPathComponent,
                size: fileSize,
                type: url.pathExtension.uppercased(),
                url: url
            )
            
            newFiles.append(fileInfo)
        }
        
        if isMultiple {
            files.append(contentsOf: newFiles)
        } else {
            files = newFiles.isEmpty ? [] : [newFiles[0]]
        }
        
        if !newFiles.isEmpty {
            onFilesSelected?(files)
        }
    }
    
    private func removeFile(_ file: FileInfo) {
        files.removeAll { $0.id == file.id }
        onFilesSelected?(files)
    }
    
    // MARK: - Helper Methods
    
    private var acceptedTypesDescription: String {
        acceptedTypes.map { $0.preferredFilenameExtension ?? $0.identifier }.joined(separator: ", ")
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func fileIcon(for type: String) -> String {
        switch type.lowercased() {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "aac":
            return "music.note"
        case "zip", "rar", "7z":
            return "doc.zipper"
        case "doc", "docx", "txt":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "ppt", "pptx":
            return "rectangle.on.rectangle.angled"
        default:
            return "doc.fill"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DKFileUpload_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKFileUpload(
                label: "Dosya Yükle",
                files: .constant([]),
                acceptedTypes: [.image, .pdf],
                maxFileSize: 10 * 1024 * 1024 // 10 MB
            )
            
            DKFileUpload(
                label: "Dosyalar",
                files: .constant([
                    DKFileUpload.FileInfo(name: "document.pdf", size: 1024000, type: "PDF"),
                    DKFileUpload.FileInfo(name: "image.jpg", size: 2048000, type: "JPG")
                ]),
                acceptedTypes: [.data]
            )
            
            DKFileUpload(
                label: "Devre Dışı",
                files: .constant([]),
                isDisabled: true
            )
        }
        .padding()
    }
}
#endif
