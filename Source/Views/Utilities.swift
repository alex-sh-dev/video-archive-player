//
//  Utilities.swift
//  Utilities
//
//  Created by dev on 2/5/26.
//

import Foundation

func rectBuilt(fromText text:String, font: UIFont,
               size: CGSize = CGSize(width: CGFLOAT_MAX, height: CGFLOAT_MAX)) -> CGRect {
    return NSString(string: text).boundingRect(
        with: size,
        options: NSStringDrawingOptions.usesLineFragmentOrigin,
        attributes: [NSAttributedString.Key.font: font],
        context: nil)
}
