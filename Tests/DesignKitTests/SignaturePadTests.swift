import XCTest
import SwiftUI
@testable import DesignKit

final class SignaturePadTests: XCTestCase {

    func test_line_initialization() {
        let point = CGPoint(x: 10, y: 15)
        let line = DKSignatureLine(points: [point])
        
        XCTAssertEqual(line.points.count, 1)
        XCTAssertEqual(line.points.first?.x, 10)
        XCTAssertEqual(line.points.first?.y, 15)
        XCTAssertNotNil(line.id)
    }

    func test_pad_initialization() {
        let lines = Binding.constant([DKSignatureLine]())
        let pad = DKSignaturePad(
            lines: lines,
            placeholder: "Testing",
            strokeColor: .red,
            strokeWidth: 5.0
        )
        
        XCTAssertEqual(pad.placeholder, "Testing")
        XCTAssertEqual(pad.strokeColor, .red)
        XCTAssertEqual(pad.strokeWidth, 5.0)
    }

    func test_export_path_empty() {
        let lines = Binding.constant([DKSignatureLine]())
        let pad = DKSignaturePad(lines: lines)
        
        let path = pad.exportPath()
        XCTAssertTrue(path.isEmpty)
    }
    
    func test_export_path_with_points() {
        let line = DKSignatureLine(points: [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)])
        var lineStore = [line]
        let pad = DKSignaturePad(lines: .init(get: { lineStore }, set: { lineStore = $0 }))
        
        let path = pad.exportPath()
        XCTAssertFalse(path.isEmpty)
    }
}
