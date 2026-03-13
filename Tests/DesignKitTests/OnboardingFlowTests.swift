import XCTest
import SwiftUI
@testable import DesignKit

final class OnboardingFlowTests: XCTestCase {

    func test_step_initialization() {
        let step = DKOnboardingStep(
            title: "Hello",
            description: "World",
            systemImage: "star",
            accentColor: .blue
        )
        
        XCTAssertEqual(step.title, "Hello")
        XCTAssertEqual(step.description, "World")
        XCTAssertEqual(step.systemImage, "star")
        XCTAssertEqual(step.accentColor, .blue)
        XCTAssertNotNil(step.id)
    }

    func test_flow_initialization() {
        var didSkip = false
        var didFinish = false
        
        let step = DKOnboardingStep(title: "1", description: "1", systemImage: "1")
        
        let flow = DKOnboardingFlow(
            steps: [step],
            onFinish: { didFinish = true },
            onSkip: { didSkip = true }
        )
        
        XCTAssertEqual(flow.steps.count, 1)
        
        flow.onFinish()
        XCTAssertTrue(didFinish)
        
        flow.onSkip()
        XCTAssertTrue(didSkip)
    }
}
