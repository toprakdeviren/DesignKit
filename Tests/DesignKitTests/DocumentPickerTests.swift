import XCTest
import SwiftUI
import UniformTypeIdentifiers
@testable import DesignKit

final class DocumentPickerTests: XCTestCase {

    func test_document_picker_initialization_and_callbacks() {
        #if os(iOS)
        var picked = false
        var canceled = false
        
        let picker = DKDocumentPicker(
            allowedContentTypes: [.pdf, .json],
            allowsMultipleSelection: true,
            onPick: { _ in picked = true },
            onCancel: { canceled = true }
        )
        
        XCTAssertEqual(picker.allowedContentTypes, [.pdf, .json])
        XCTAssertTrue(picker.allowsMultipleSelection)
        
        // Execute callbacks locally
        picker.onPick([])
        XCTAssertTrue(picked)
        
        picker.onCancel()
        XCTAssertTrue(canceled)
        #endif
    }
    
    func test_modifier_compiling_safely() {
        // Assert the modifier can hook to a structural unit properly to prevent protocol mismatch errors
        let view: AnyView = AnyView(
            Text("Dummy")
                .dkDocumentPicker(isPresented: .constant(true), onPick: { _ in })
        )
        
        XCTAssertNotNil(view)
    }
}
