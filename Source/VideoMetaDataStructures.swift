//
//  VideoMetaDataStructures.swift
//  VideoArchivePlayer
//
//  Created by dev on 3/17/26.
//

import Foundation

final class VideoMetaData: Decodable {
    var name: String = ""
    var date: Date = Date.now
    var videoSize: CGSize = .zero
    var videoFileList = VideoFileList()

    enum CodingKeys: String, CodingKey {
        case name
        case date
        case video_size
        case paths
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        if let dateStr = try container.decodeIfPresent(String.self, forKey: .date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMyyyy"
            self.date = dateFormatter.date(from: dateStr) ?? Date.distantPast
        }
        if let videoSizeStr = try container.decodeIfPresent(String.self, forKey: .video_size) {
            let sizeList = videoSizeStr.split(separator: "x")
            if sizeList.count > 1 {
                let w = Int(sizeList[0]) ?? 0
                let h = Int(sizeList[1]) ?? 0
                self.videoSize = w > 0 && h > 0 ? CGSize(width: w, height: h) : .zero
            }
        }
        let paths = try container.decode([VideoMetaDataPath].self, forKey: .paths)
        paths.forEach { path in
            self.videoFileList.append(time: path.time, duration: path.duration, path: path.url)
        }
    }
}

class VideoMetaDataPath: Decodable {
    var url: String
    var time: UInt
    var duration: UInt

    enum CodingKeys: String, CodingKey {
        case url
        case time
        case duration
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.time = try container.decode(UInt.self, forKey: .time)
        self.duration = try container.decode(UInt.self, forKey: .duration)
    }
}
