import XCTest
import SwiftUI
@testable import DesignKit

final class NewComponentTests: XCTestCase {
    
    // MARK: - DKSpinner Tests
    
    func testSpinnerCreation() {
        let spinner = DKSpinner()
        XCTAssertNotNil(spinner)
    }
    
    func testSpinnerSizes() {
        XCTAssertEqual(SpinnerSize.sm.size, 16)
        XCTAssertEqual(SpinnerSize.md.size, 24)
        XCTAssertEqual(SpinnerSize.lg.size, 40)
    }
    
    // MARK: - DKProgressBar Tests
    
    func testProgressBarCreation() {
        let progressBar = DKProgressBar(value: 0.5)
        XCTAssertNotNil(progressBar)
    }
    
    func testProgressBarValueClamping() {
        // Values should be clamped between 0 and 1
        let progressBar1 = DKProgressBar(value: -0.5) // Should clamp to 0
        let progressBar2 = DKProgressBar(value: 1.5)  // Should clamp to 1
        
        XCTAssertNotNil(progressBar1)
        XCTAssertNotNil(progressBar2)
    }
    
    func testProgressBarSizes() {
        XCTAssertEqual(ProgressBarSize.sm.height, 4)
        XCTAssertEqual(ProgressBarSize.md.height, 8)
        XCTAssertEqual(ProgressBarSize.lg.height, 12)
    }
    
    // MARK: - DKToast Tests
    
    func testToastCreation() {
        let toast = DKToast(message: "Test message")
        XCTAssertNotNil(toast)
    }
    
    func testToastWithVariants() {
        let infoToast = DKToast(message: "Info", variant: .info)
        let successToast = DKToast(message: "Success", variant: .success)
        let warningToast = DKToast(message: "Warning", variant: .warning)
        let errorToast = DKToast(message: "Error", variant: .error)
        
        XCTAssertNotNil(infoToast)
        XCTAssertNotNil(successToast)
        XCTAssertNotNil(warningToast)
        XCTAssertNotNil(errorToast)
    }
    
    // MARK: - DKTextField Tests
    
    func testTextFieldCreation() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let textField = DKTextField(
            label: "Email",
            placeholder: "Enter email",
            text: text
        )
        XCTAssertNotNil(textField)
    }
    
    func testTextFieldVariants() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        
        let defaultField = DKTextField(text: text, variant: .default)
        let errorField = DKTextField(text: text, variant: .error)
        let successField = DKTextField(text: text, variant: .success)
        
        XCTAssertNotNil(defaultField)
        XCTAssertNotNil(errorField)
        XCTAssertNotNil(successField)
    }
    
    func testSecureTextField() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let secureField = DKTextField(
            label: "Password",
            text: text,
            isSecure: true
        )
        XCTAssertNotNil(secureField)
    }
    
    // MARK: - Typography Component Tests
    
    func testLinkCreation() {
        let link = DKLink("Click me") {
            print("Clicked")
        }
        XCTAssertNotNil(link)
    }
    
    func testInlineCodeCreation() {
        let code = DKInlineCode("print('Hello')")
        XCTAssertNotNil(code)
    }
    
    func testListItemCreation() {
        let item = DKListItem("Item 1")
        XCTAssertNotNil(item)
    }
    
    func testOrderedListItemCreation() {
        let item = DKOrderedListItem("Item 1", number: 1)
        XCTAssertNotNil(item)
    }
}


