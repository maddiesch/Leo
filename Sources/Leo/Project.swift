//
//  Project.swift
//  
//
//  Created by Maddie Schipper on 5/28/20.
//

import Foundation
import Combine

public final class Project : Identifiable, ObservableObject, Codable {
    public let id: UUID
    
    @Published public var name: String
    
    @Published private(set) var layers: Array<Layer>
    
    @Published public var size: Size {
        didSet {
            for layer in self.layers {
                layer.resize(size)
            }
        }
    }
    
    public init(name: String, size: Size) {
        self.id = UUID()
        self.name = name
        self.layers = []
        self.size = size
    }
    
    @discardableResult
    func addLayer(withName name: String) -> Layer {
        let layer = Layer(name: name)
        layer.project = self
        self.layers.append(layer)
        return layer
    }
    
    private enum CodingKeys : Int, CodingKey {
        case id = 0
        case name = 1
        case layers = 2
        case size = 3
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        self.layers.forEach { $0.cull(self.size) }
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.layers, forKey: .layers)
        try container.encode(self.size, forKey: .size)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.layers = try container.decode(Array<Layer>.self, forKey: .layers)
        self.size = try container.decode(Size.self, forKey: .size)
    }
}

public struct Size : Codable {
    public var width: UInt16
    public let height: UInt16
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        var data = Data()
        data.append(self.width.bigEndianData)
        data.append(self.height.bigEndianData)
        
        try container.encode(UInt32(bigEndianData: data).bigEndian)
    }
    
    public init(_ width: UInt16, _ height: UInt16) {
        self.width = width
        self.height = height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = UInt32(bigEndian: try container.decode(UInt32.self)).bigEndianData
        
        self.width = UInt16(bigEndianData: data.subdata(in: 0..<2))
        self.height = UInt16(bigEndianData: data.subdata(in: 2..<4))
    }
}
