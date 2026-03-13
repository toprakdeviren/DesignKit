import XCTest
import SwiftUI
@testable import DesignKit

final class VoiceMessagePlayerTests: XCTestCase {

    func test_initialization() {
        let samples: [CGFloat] = [0.1, 0.5, 0.9]
        let player = DKVoiceMessagePlayer(
            isPlaying: true,
            progress: 0.5,
            duration: 120.0,
            samples: samples,
            onPlayPause: {}
        )
        
        XCTAssertTrue(player.isPlaying)
        XCTAssertEqual(player.progress, 0.5)
        XCTAssertEqual(player.duration, 120.0)
        XCTAssertEqual(player.samples, samples)
    }

    func test_progress_clamping() {
        let playerUnder = DKVoiceMessagePlayer(
            isPlaying: false, progress: -0.5, duration: 10, samples: [], onPlayPause: {}
        )
        XCTAssertEqual(playerUnder.progress, 0.0)
        
        let playerOver = DKVoiceMessagePlayer(
            isPlaying: false, progress: 1.5, duration: 10, samples: [], onPlayPause: {}
        )
        XCTAssertEqual(playerOver.progress, 1.0)
    }

    func test_duration_max_zero() {
        let player = DKVoiceMessagePlayer(
            isPlaying: false, progress: 0.5, duration: -10.0, samples: [], onPlayPause: {}
        )
        XCTAssertEqual(player.duration, 0.0)
    }
}
