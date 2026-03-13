import XCTest
import SwiftUI
@testable import DesignKit

final class NewComponentsTests: XCTestCase {
    
    // MARK: - Color Picker Tests
    
    func testColorPickerInitialization() {
        let selectedColor = Binding<Color>(get: { .blue }, set: { _ in })
        let colorPicker = DKColorPicker(
            label: "Test Color",
            selectedColor: selectedColor
        )
        XCTAssertNotNil(colorPicker)
    }
    
    func testColorPickerWithAlpha() {
        let selectedColor = Binding<Color>(get: { .blue }, set: { _ in })
        let colorPicker = DKColorPicker(
            label: "Test Color",
            selectedColor: selectedColor,
            showAlpha: true
        )
        XCTAssertNotNil(colorPicker)
    }
    
    func testColorPickerDisabled() {
        let selectedColor = Binding<Color>(get: { .blue }, set: { _ in })
        let colorPicker = DKColorPicker(
            label: "Test Color",
            selectedColor: selectedColor,
            isDisabled: true
        )
        XCTAssertNotNil(colorPicker)
    }
    
    func testColorPickerPresets() {
        let presets = DKColorPicker.defaultPresets
        XCTAssertFalse(presets.isEmpty)
        XCTAssertEqual(presets.count, 16)
    }
    
    // MARK: - File Upload Tests
    
    func testFileUploadInitialization() {
        let files = Binding<[DKFileUpload.FileInfo]>(get: { [] }, set: { _ in })
        let fileUpload = DKFileUpload(
            label: "Upload Files",
            files: files
        )
        XCTAssertNotNil(fileUpload)
    }
    
    func testFileUploadMultiple() {
        let files = Binding<[DKFileUpload.FileInfo]>(get: { [] }, set: { _ in })
        let fileUpload = DKFileUpload(
            label: "Upload Files",
            files: files,
            isMultiple: true
        )
        XCTAssertNotNil(fileUpload)
    }
    
    func testFileUploadSingle() {
        let files = Binding<[DKFileUpload.FileInfo]>(get: { [] }, set: { _ in })
        let fileUpload = DKFileUpload(
            label: "Upload File",
            files: files,
            isMultiple: false
        )
        XCTAssertNotNil(fileUpload)
    }
    
    func testFileInfoCreation() {
        let fileInfo = DKFileUpload.FileInfo(
            name: "test.pdf",
            size: 1024000,
            type: "PDF"
        )
        
        XCTAssertEqual(fileInfo.name, "test.pdf")
        XCTAssertEqual(fileInfo.size, 1024000)
        XCTAssertEqual(fileInfo.type, "PDF")
        XCTAssertFalse(fileInfo.formattedSize.isEmpty)
    }
    
    func testFileInfoFormattedSize() {
        let fileInfo = DKFileUpload.FileInfo(
            name: "test.pdf",
            size: 1024,
            type: "PDF"
        )
        
        let formattedSize = fileInfo.formattedSize
        XCTAssertTrue(formattedSize.contains("KB") || formattedSize.contains("B"))
    }
    
    // MARK: - Chart Tests
    
    func testChartInitialization() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10),
            DKChart.DataPoint(label: "B", value: 20),
            DKChart.DataPoint(label: "C", value: 15)
        ]
        
        let chart = DKChart(
            title: "Test Chart",
            data: data
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartBarType() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10),
            DKChart.DataPoint(label: "B", value: 20)
        ]
        
        let chart = DKChart(
            title: "Bar Chart",
            data: data,
            type: .bar
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartLineType() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10),
            DKChart.DataPoint(label: "B", value: 20)
        ]
        
        let chart = DKChart(
            title: "Line Chart",
            data: data,
            type: .line
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartPieType() {
        let data = [
            DKChart.DataPoint(label: "A", value: 30, color: .red),
            DKChart.DataPoint(label: "B", value: 40, color: .blue),
            DKChart.DataPoint(label: "C", value: 30, color: .green)
        ]
        
        let chart = DKChart(
            title: "Pie Chart",
            data: data,
            type: .pie
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartAreaType() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10),
            DKChart.DataPoint(label: "B", value: 20)
        ]
        
        let chart = DKChart(
            title: "Area Chart",
            data: data,
            type: .area
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartDataPoint() {
        let dataPoint = DKChart.DataPoint(
            label: "Test",
            value: 100,
            color: .blue
        )
        
        XCTAssertEqual(dataPoint.label, "Test")
        XCTAssertEqual(dataPoint.value, 100)
        XCTAssertNotNil(dataPoint.color)
    }
    
    func testChartWithLegend() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10)
        ]
        
        let chart = DKChart(
            title: "Chart",
            data: data,
            showLegend: true
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartWithoutValues() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10)
        ]
        
        let chart = DKChart(
            title: "Chart",
            data: data,
            showValues: false
        )
        XCTAssertNotNil(chart)
    }
    
    func testChartWithoutAnimation() {
        let data = [
            DKChart.DataPoint(label: "A", value: 10)
        ]
        
        let chart = DKChart(
            title: "Chart",
            data: data,
            animated: false
        )
        XCTAssertNotNil(chart)
    }
}

