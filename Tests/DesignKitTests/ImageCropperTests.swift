import XCTest
import SwiftUI
@testable import DesignKit

final class ImageCropperTests: XCTestCase {

    func test_initialization() {
#if canImport(UIKit)
        let dummyImage = UIImage()
        var didCancel = false
        
        let cropper = DKImageCropper(
            image: dummyImage,
            cropSize: CGSize(width: 200, height: 200),
            onCrop: { _ in },
            onCancel: { didCancel = true }
        )
        
        XCTAssertNotNil(cropper.image)
        XCTAssertEqual(cropper.cropSize.width, 200)
        
        // trigger blocks cleanly
        cropper.onCancel()
        XCTAssertTrue(didCancel)
#else
        let dummyImage = NSImage()
        let cropper = DKImageCropper(
            image: dummyImage,
            onCrop: { _ in },
            onCancel: {}
        )
        XCTAssertNotNil(cropper.image)
#endif
    }
}
