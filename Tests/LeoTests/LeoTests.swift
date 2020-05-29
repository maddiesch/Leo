import XCTest
@testable import Leo

final class LeoTests: XCTestCase {
    var project: Project = {
        let proj = Project(name: "Test Project", size: Size(16, 16))
        let layer = proj.addLayer(withName: "Testing Layers")
        
        layer.set(Color(128, 0, 170, 1.0), atIndex: Index(8, 8))
        layer.set(Color(128, 78, 0, 1.0), atIndex: Index(9, 7))
        layer.set(Color(128, 123, 85, 1.0), atIndex: Index(7, 5))
        
        return proj
    }()
    
    func testEncodingSanity() throws {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(project)
        
        XCTAssertNotNil(data)
    }
    
    func testDecodingSanity() throws {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(project)
        
        let out = try JSONDecoder().decode(Project.self, from: data)
        
        XCTAssertNotNil(out)
    }
    
    func testImageRender() throws {
        let image = try render(project, toImageWithType: .png)
        
        XCTAssertNotNil(image)
    }
    
    func testLayerResizing() {
        let proj = Project(name: "Resized", size: Size(16, 16))
        let layer = proj.addLayer(withName: "layer-1")
        layer.set(Color(0, 0, 0, 1.0), atIndex: Index(12, 14))
        layer.set(Color(0, 0, 0, 1.0), atIndex: Index(5, 8))
        layer.set(Color(0, 0, 0, 1.0), atIndex: Index(7, 7))
        
        proj.size = Size(8, 8)
        
        XCTAssertNil(layer.pixel(at: Index(12, 14)))
        XCTAssertNil(layer.pixel(at: Index(5, 8)))
        
        XCTAssertNotNil(layer.pixel(at: Index(7, 7)))
    }
}
