//
//  Global.swift
//  Global
//
//  Created by dev on 1/29/26.
//

import Foundation

class Unsafe {
    static func bridge<T: AnyObject>(obj: T) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    }

    static func bridge<T: AnyObject>(ptr: UnsafeMutableRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    }

    static func bridgeRetained<T: AnyObject>(obj: T) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(Unmanaged.passRetained(obj).toOpaque())
    }

    static func bridgeRetained<T: AnyObject>(ptr: UnsafeMutableRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
    }

    static func destroy<T: AnyObject>(ptr: UnsafeMutableRawPointer, for _: T.Type) {
        Unmanaged<T>.fromOpaque(ptr).release()
    }
}
