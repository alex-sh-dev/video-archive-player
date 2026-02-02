//
//  Files.swift
//  Files
//
//  Created by dev on 2/2/26.
//

import Foundation

struct VideoFileInfo {
    /// Creation time of file in unix time
    var creationTime: UInt = 0
    /// Duration of video file
    var duration: UInt = 0
    /// Size of video
    var size: CGSize = CGSizeZero
    
    init() {}
    
    init(creationTime: UInt, duration: UInt, size: CGSize) {
        self.creationTime = creationTime
        self.duration = duration
        self.size = size
    }
    
    /// Returns the converted creation time (in seconds) from the interval [0, 86400) using the device's current time zone.
    func numericalCreationTime() -> (succes: Bool, result: UInt) {
        let date = Date(timeIntervalSince1970: Double(self.creationTime))
        let calendar = Calendar(identifier: .gregorian)
        let cmps = calendar.dateComponents([.hour, .minute, .second], from: date)
        if let h = cmps.hour, h >= 0,
           let m = cmps.minute, m >= 0,
           let s = cmps.second, s >= 0 {
            return (true, UInt(h * 3600 + m * 60 + s))
        }
        
        return (false, 0)
    }
}

final class VideoFileList {
    var count: UInt {
        return UInt(_info.count)
    }
    
    var first: (info: VideoFileInfo, path: String)? {
        return self[0]
    }
    
    var last: (info: VideoFileInfo, path: String)? {
        if self.count > 0 {
            return self[self.count - 1]
        } else {
            return nil
        }
    }
    
    var paths: [String] {
        return _paths
    }
    
    private var _info = [VideoFileInfo]()
    private var _paths = [String]()

    init() {}
    
    func append(creationTime: UInt, duration: UInt, path: String, size: CGSize) {
        _info.append(VideoFileInfo(creationTime: creationTime, duration: duration, size: size))
        _paths.append(path)
    }
    
    func append(info: VideoFileInfo, path: String) {
        _info.append(info)
        _paths.append(path)
    }
    
    private func validIndex(_ index: UInt) -> Bool {
        return index >= 0 && index < self.count
    }
    
    func remove(at index: UInt) {
        if validIndex(index) {
            _info.remove(at: Int(index))
            _paths.remove(at: Int(index))
        }
    }
    
    subscript(index: UInt) -> (info: VideoFileInfo, path: String)? {
        get {
            if !validIndex(index) {
                return nil
            }
            return (_info[Int(index)], _paths[Int(index)])
        }
        set(newValue) {
            if validIndex(index) && newValue != nil {
                _info[Int(index)] = newValue!.info
                _paths[Int(index)] = newValue!.path
            }
        }
    }
}
