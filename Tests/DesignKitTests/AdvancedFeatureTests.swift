import XCTest
import SwiftUI
@testable import DesignKit

final class AdvancedFeatureTests: XCTestCase {
    
    // MARK: - Form Validation Tests
    
    func testRequiredValidation() {
        let result1 = FormValidator.validate("", rule: .required)
        let result2 = FormValidator.validate("test", rule: .required)
        
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result2.isValid)
    }
    
    func testEmailValidation() {
        let result1 = FormValidator.validate("invalid", rule: .email)
        let result2 = FormValidator.validate("test@example.com", rule: .email)
        
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result2.isValid)
    }
    
    func testMinLengthValidation() {
        let result1 = FormValidator.validate("abc", rule: .minLength(5))
        let result2 = FormValidator.validate("abcdef", rule: .minLength(5))
        
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result2.isValid)
    }
    
    func testMaxLengthValidation() {
        let result1 = FormValidator.validate("abcdefgh", rule: .maxLength(5))
        let result2 = FormValidator.validate("abc", rule: .maxLength(5))
        
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result2.isValid)
    }
    
    func testCustomValidation() {
        let rule = ValidationRule.custom({ value in
            return value.contains("test")
        }, message: "Must contain 'test'")
        
        let result1 = FormValidator.validate("hello", rule: rule)
        let result2 = FormValidator.validate("test123", rule: rule)
        
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result2.isValid)
    }
    
    func testMultipleRules() {
        let rules: [ValidationRule] = [
            .required,
            .minLength(3),
            .maxLength(10)
        ]
        
        let result1 = FormValidator.validate("", rules: rules)
        let result2 = FormValidator.validate("ab", rules: rules)
        let result3 = FormValidator.validate("valid", rules: rules)
        
        XCTAssertFalse(result1.isValid)
        XCTAssertFalse(result2.isValid)
        XCTAssertTrue(result3.isValid)
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    func testFormField() {
        let field = FormField(
            initialValue: "",
            rules: [.required, .email]
        )
        
        XCTAssertTrue(field.isValid) // Initially valid (not validated yet)
        
        let result = field.validate()
        XCTAssertFalse(result.isValid)
        
        field.value = "test@example.com"
        let result2 = field.validate()
        XCTAssertTrue(result2.isValid)
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    func testFormContainer() {
        let emailField = FormField(
            initialValue: "",
            rules: [.required, .email]
        )
        
        let nameField = FormField(
            initialValue: "",
            rules: [.required, .minLength(2)]
        )
        
        let form = Form(fields: [
            "email": emailField,
            "name": nameField
        ])
        
        let isValid = form.validateAll()
        XCTAssertFalse(isValid)
        
        emailField.value = "test@example.com"
        nameField.value = "John"
        
        let isValid2 = form.validateAll()
        XCTAssertTrue(isValid2)
    }
    
    // MARK: - DKBottomSheet Tests
    
    func testBottomSheetDetentHeights() {
        let screenHeight: CGFloat = 800
        
        XCTAssertEqual(BottomSheetDetent.small.height(screenHeight: screenHeight), 200)
        XCTAssertEqual(BottomSheetDetent.medium.height(screenHeight: screenHeight), 400)
        XCTAssertEqual(BottomSheetDetent.large.height(screenHeight: screenHeight), 720)
        XCTAssertEqual(BottomSheetDetent.custom(300).height(screenHeight: screenHeight), 300)
    }
    
    func testBottomSheetInitialization() {
        let sheet = DKBottomSheet(
            isPresented: .constant(true),
            detents: [.medium],
            showDragIndicator: true
        ) {
            Text("Content")
        }
        
        XCTAssertNotNil(sheet)
    }
    
    // MARK: - DKInfiniteScroll Tests
    
    func testInfiniteScrollInitialization() {
        struct TestData: Identifiable {
            let id: UUID
            let title: String
        }
        
        let data = [
            TestData(id: UUID(), title: "Item 1"),
            TestData(id: UUID(), title: "Item 2")
        ]
        
        let scroll = DKInfiniteScroll(
            data: data,
            isLoading: false,
            hasMore: true,
            onLoadMore: {}
        ) { item in
            Text(item.title)
        }
        
        XCTAssertNotNil(scroll)
    }
    
    // MARK: - DKPullToRefresh Tests
    
    func testPullToRefreshInitialization() {
        let refresh = DKPullToRefresh(
            onRefresh: {
                // Async refresh action
            }
        ) {
            Text("Content")
        }
        
        XCTAssertNotNil(refresh)
    }
}

