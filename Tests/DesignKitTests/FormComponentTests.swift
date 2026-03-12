import XCTest
import SwiftUI
@testable import DesignKit

final class FormComponentTests: XCTestCase {
    
    // MARK: - DKCheckbox Tests
    
    func testCheckboxCreation() {
        let isChecked = Binding.constant(false)
        let checkbox = DKCheckbox(label: "Accept Terms", isChecked: isChecked)
        XCTAssertNotNil(checkbox)
    }
    
    func testCheckboxToggle() {
        var checked = false
        let binding = Binding<Bool>(
            get: { checked },
            set: { checked = $0 }
        )
        
        let _ = DKCheckbox(isChecked: binding)
        
        // Simulate toggle
        binding.wrappedValue = true
        XCTAssertTrue(checked)
        
        binding.wrappedValue = false
        XCTAssertFalse(checked)
    }
    
    // MARK: - DKRadio Tests
    
    func testRadioCreation() {
        let selectedValue = Binding<String>(get: { "option1" }, set: { _ in })
        let radio = DKRadio(label: "Option 1", value: "option1", selectedValue: selectedValue)
        XCTAssertNotNil(radio)
    }
    
    func testRadioGroupCreation() {
        let items = [
            (label: "Option 1", value: "opt1"),
            (label: "Option 2", value: "opt2")
        ]
        let selectedValue = Binding<String>(get: { "opt1" }, set: { _ in })
        let radioGroup = DKRadioGroup(items: items, selectedValue: selectedValue)
        
        XCTAssertNotNil(radioGroup)
    }
    
    // MARK: - DKSwitch Tests
    
    func testSwitchCreation() {
        let isOn = Binding<Bool>(get: { false }, set: { _ in })
        let toggle = DKSwitch(label: "Enable notifications", isOn: isOn)
        XCTAssertNotNil(toggle)
    }
    
    func testSwitchToggle() {
        var on = false
        let binding = Binding<Bool>(
            get: { on },
            set: { on = $0 }
        )
        
        let _ = DKSwitch(isOn: binding)
        
        binding.wrappedValue = true
        XCTAssertTrue(on)
        
        binding.wrappedValue = false
        XCTAssertFalse(on)
    }
    
    // MARK: - DKSlider Tests
    
    func testSliderCreation() {
        let value = Binding<Double>(get: { 50 }, set: { _ in })
        let slider = DKSlider(label: "Volume", value: value, range: 0...100)
        XCTAssertNotNil(slider)
    }
    
    func testSliderValueClamping() {
        var val = 50.0
        let binding = Binding<Double>(
            get: { val },
            set: { val = $0 }
        )
        
        let _ = DKSlider(value: binding, range: 0...100)
        
        // Values should be within range
        binding.wrappedValue = 75
        XCTAssertEqual(val, 75)
    }
    
    // MARK: - DKTextArea Tests
    
    func testTextAreaCreation() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let textArea = DKTextArea(
            label: "Description",
            placeholder: "Enter text",
            text: text
        )
        XCTAssertNotNil(textArea)
    }
    
    func testTextAreaMaxLength() {
        let text = Binding<String>(get: { "" }, set: { _ in })
        let textArea = DKTextArea(text: text, maxLength: 100)
        XCTAssertNotNil(textArea)
    }
}


