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
    
    init(creationTime: UInt, duration: UInt) {
        self.creationTime = creationTime
        self.duration = duration
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
    private var _info = [VideoFileInfo]()
    private var _paths = [String]()
    
    func append(creationTime: UInt, duration: UInt, path: String) {
        _info.append(VideoFileInfo(creationTime: creationTime, duration: duration))
        _paths.append(path)
    }
    
    func append(info: VideoFileInfo, path: String) {
        _info.append(info)
        _paths.append(path)
    }
    
    subscript(index: Int) -> (info: VideoFileInfo, path: String) {
        get {
            return (_info[index], _paths[index])
        }
        set(newValue) {
            _info[index] = newValue.info
            _paths[index] = newValue.path
        }
    }
    
    func count() -> Int {
        return _info.count
    }
    
    func paths() -> [String] {
        return _paths
    }
}
