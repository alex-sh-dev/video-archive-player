//
//  Object.swift
//  Extensions
//
//  Created by dev on 3/18/26.
//

import Foundation

extension NSObject {
  var className: String {
      return String(describing: type(of: self))
  }

  class var className: String {
      return String(describing: self)
  }
}
