//
//  Window.swift
//  Extensions
//
//  Created by dev on 3/18/26.
//

import Foundation

extension UIWindow {
    static var isLandscape: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.interfaceOrientation.isLandscape ?? false
    }
}
