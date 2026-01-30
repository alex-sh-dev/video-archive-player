//
//  VLCExtensions.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/29/26.
//

import Foundation

extension VLCMedia {
    /// Sets object to userData
    ///
    /// Call only when you are sure that the object is not set. Multiple calls can cause memory leaks (zombie objects)
    func setObject<T: AnyObject>(object: T) {
        let ptr = Unsafe.bridgeRetained(obj: object)
        self.setUserData(ptr)
    }
    
    /// Receives object (userData)
    ///
    /// Call only when you are sure that the object is set, otherwise exception (EXC_BAD_ACCESS)
    func object<T: AnyObject>() -> T {
        return Unsafe.bridge(ptr: self.userData())
    }
    
    /// Releases object (userData)
    ///
    /// Call only when you are sure that the object is set, otherwise exception (EXC_BAD_ACCESS)
    func releaseObject<T: AnyObject>(type: T.Type) {
        Unsafe.destroy(ptr: self.userData(), for: type)
    }
}
