//
//  Layer.swift
//  
//
//  Created by Maddie Schipper on 5/28/20.
//

import Foundation
import Combine

public final class Layer : Identifiable, ObservableObject, Codable {
    @Published public var name: String
    
    public let id: UUID
    
    weak internal(set) public var project: Project?
    
    private var storage: Dictionary<Index, Color>
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.storage = [:]
    }
    
    internal func resize(_ size: Size) {
        self.cull(size)
    }
    
    internal func cull(_ size: Size) {
        let last = Index(size.width - 1, size.height - 1)
        for index in self.storage.keys {
            if index.x > last.x || index.y > last.y {
                self.storage.removeValue(forKey: index)
            } else if self.storage[index]!.alpha <= 0.0 {
                self.storage.removeValue(forKey: index)
            }
        }
    }
    
    public func pixel(at: Index) -> Color? {
        return self.storage[at]
    }
    
    // Coding
    private enum CodingKeys : Int, CodingKey {
        case id = 0
        case name = 1
        case pixels = 2
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.storage, forKey: .pixels)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.storage = try container.decode(Dictionary<Index, Color>.self, forKey: .pixels)
    }
    
    public func set(_ color: Color, atIndex index: Index) {
        self.storage[index] = color
    }
}

public struct Index : Codable, Equatable, Comparable, Hashable {
    public let x: UInt16
    public let y: UInt16
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        var data = Data()
        data.append(self.x.bigEndianData)
        data.append(self.y.bigEndianData)
        
        try container.encode(UInt32(bigEndianData: data).bigEndian)
    }
    
    public init(_ x: UInt16, _ y: UInt16) {
        self.x = x
        self.y = y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = UInt32(bigEndian: try container.decode(UInt32.self)).bigEndianData
        
        self.x = UInt16(bigEndianData: data.subdata(in: 0..<2))
        self.y = UInt16(bigEndianData: data.subdata(in: 2..<4))
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
    
    public static func ==(lhs: Index, rhs: Index) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public static func < (lhs: Index, rhs: Index) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
}

public struct Color : Codable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: Double
    
    internal var dRed: Double {
        return Double(self.red) / 255.0
    }
    
    internal var dGreen: Double {
        return Double(self.green) / 255.0
    }
    
    internal var dBlue: Double {
        return Double(self.blue) / 255.0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        var data = Data()
        
        data.append(self.red.bigEndianData)
        data.append(self.green.bigEndianData)
        data.append(self.blue.bigEndianData)
        data.append(0x00)
        data.append(Float(self.alpha).bitPattern.bigEndianData)
        
        try container.encode(UInt64(bigEndianData: data).bigEndian)
    }
    
    public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = UInt64(bigEndian: try container.decode(UInt64.self)).bigEndianData
        
        self.red = UInt8(bigEndianData: data.subdata(in: 0..<1))
        self.green = UInt8(bigEndianData: data.subdata(in: 1..<2))
        self.blue = UInt8(bigEndianData: data.subdata(in: 2..<3))
        self.alpha = Double(Float(bitPattern: UInt32(bigEndianData: data.subdata(in: 4..<8))))
    }
}

#if canImport(CoreGraphics)

import CoreGraphics

public extension Color {
    var cgColor: CGColor {
        return CGColor(red: CGFloat(self.dRed), green: CGFloat(self.dGreen), blue: CGFloat(self.dBlue), alpha: CGFloat(self.alpha))
    }
}

#endif
