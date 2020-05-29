//
//  Coding.swift
//  
//
//  Created by Maddie Schipper on 5/28/20.
//

import Foundation

internal extension FixedWidthInteger {
    var bigEndianData: Data {
        var v = self.bigEndian
        return Data(bytes: &v, count: MemoryLayout.size(ofValue: v))
    }
    
    init(bigEndianData data: Data) {
        var value: Self = 0
        _ = withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0) }
        self.init(bigEndian: value)
    }
}
