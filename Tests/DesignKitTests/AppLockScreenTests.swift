import XCTest
import SwiftUI
@testable import DesignKit

final class AppLockScreenTests: XCTestCase {

    func test_initialization() {
        let lockScreen = DKAppLockScreen(
            pinLength: 6,
            biometricReason: "For testing",
            onPinEntered: { _ in true },
            onBiometricSuccess: {}
        )
        
        XCTAssertEqual(lockScreen.pinLength, 6)
        XCTAssertEqual(lockScreen.biometricReason, "For testing")
        XCTAssertNotNil(lockScreen.onBiometricSuccess)
    }

    func test_pin_length_clamping() {
        let lock1 = DKAppLockScreen(pinLength: 2, onPinEntered: { _ in true }) // lower bound
        let lock2 = DKAppLockScreen(pinLength: 10, onPinEntered: { _ in true }) // upper bound
        
        XCTAssertEqual(lock1.pinLength, 4) // minimum is 4
        XCTAssertEqual(lock2.pinLength, 8) // maximum is 8
    }

    func test_default_values() {
        let lockScreen = DKAppLockScreen(onPinEntered: { _ in true })
        XCTAssertEqual(lockScreen.pinLength, 4)
        XCTAssertNil(lockScreen.biometricReason)
        XCTAssertNil(lockScreen.onBiometricSuccess)
    }
}
