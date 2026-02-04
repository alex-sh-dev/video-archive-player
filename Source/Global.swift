//
//  Global.swift
//  Global
//
//  Created by dev on 1/29/26.
//

import Foundation

final class Unsafe {
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

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

func easyLog(_ text: String = "", funcName: String = #function) {
#if DEBUG
    print(funcName)
    if !text.isEmpty {
        print(text)
    }
#endif
}

func rectBuilt(fromText text:String, font: UIFont,
               size: CGSize = CGSize(width: CGFLOAT_MAX, height: CGFLOAT_MAX)) -> CGRect {
    return NSString(string: text).boundingRect(
        with: size,
        options: NSStringDrawingOptions.usesLineFragmentOrigin,
        attributes: [NSAttributedString.Key.font: font],
        context: nil)
}

extension UIWindow {
    static var isLandscape: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.interfaceOrientation.isLandscape ?? false
    }
}
