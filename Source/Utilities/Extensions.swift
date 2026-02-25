//
//  Extensions.swift
//  Extensions
//
//  Created by dev on 2/5/26.
//

import Foundation

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

extension UIWindow {
    static var isLandscape: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.interfaceOrientation.isLandscape ?? false
    }
}

extension NSObject {
  var className: String {
      return String(describing: type(of: self))
  }

  class var className: String {
      return String(describing: self)
  }
}
