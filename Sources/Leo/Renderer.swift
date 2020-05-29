//
//  Renderer.swift
//  
//
//  Created by Maddie Schipper on 5/28/20.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics

public enum RenderError : Swift.Error {
    case failedToCreateColorSpace(String)
    case failedToCreateBitmapContext
    case failedToCreateImage
    case failedToCreateImageData
    case failedToCreateImageDestination
    case failedToCreateImageOfType(RenderImageType)
}

public enum RenderImageType {
    case png
    
    var cfType: CFString {
        switch self {
        case .png:
            return kUTTypePNG
        }
    }
}

public func render(_ project: Project, toImageWithType type: RenderImageType) throws -> Data {
    let img = try render(project)
    
    guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
        throw RenderError.failedToCreateImageData
    }
    guard let dest = CGImageDestinationCreateWithData(data, type.cfType, 1, nil) else {
        throw RenderError.failedToCreateImageDestination
    }
    
    CGImageDestinationAddImage(dest, img, nil)
    
    guard CGImageDestinationFinalize(dest) else {
        throw RenderError.failedToCreateImageOfType(type)
    }
    
    return data as Data
}

public func render(_ project: Project) throws -> CGImage {
    guard let color = CGColorSpace(name: CGColorSpace.sRGB) else {
        throw RenderError.failedToCreateColorSpace(CGColorSpace.sRGB as String)
    }
    let context = CGContext(
        data: nil,
        width: Int(project.size.width),
        height: Int(project.size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: color,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    )
    
    guard let ctx = context else {
        throw RenderError.failedToCreateBitmapContext
    }
    
    ctx.saveGState()
    
    render(project, inContext: ctx)
    
    ctx.restoreGState()
    
    guard let image = ctx.makeImage() else {
        throw RenderError.failedToCreateImage
    }
    
    return image
}

public func render(_ project: Project, inContext ctx: CGContext) {
    for layer in project.layers {
        ctx.saveGState()
        render(layer, withSize: project.size, inContext: ctx)
        ctx.restoreGState()
    }
}

internal func render(_ layer: Layer, withSize size: Size, inContext ctx: CGContext) {
    ctx.saveGState()
    for x in 0 ..< size.height {
        for y in 0 ..< size.width {
            if let color = layer.pixel(at: Index(UInt16(x), UInt16(y))) {
                ctx.setFillColor(color.cgColor)
                ctx.fill(CGRect(x: Int(x), y: Int(y), width: 1, height: 1))
            }
        }
    }
}

#endif
