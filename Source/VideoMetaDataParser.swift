//
//  VideoMetaDataParser.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/5/26.
//

import Foundation

enum ParseError {
    case parseFailed
    case jsonLoadFailed
    case urlEmpty
    case urlInvalid
    case jsonDataEmpty
    
    func desc() -> String {
        switch (self) {
        case .jsonLoadFailed:
            return "JSON load failed!"
        case .parseFailed:
            return "JSON parse failed!"
        case .urlEmpty:
            return "Json url empty!"
        case .urlInvalid:
            return "Json url invalid!"
        default:
            return "Json data is empty or part is missing!"
        }
    }
}

final class VideoMetaDataParseResult {
    var name: String = ""
    var date: Date = Date.now
    var videoSize: CGSize = .zero
    var videoFileList = VideoFileList()
}

protocol VideoMetaDataParserDelegate: AnyObject {
    func parseFailed(err: ParseError)
    func parseFinished(result: VideoMetaDataParseResult)
}

final class VideoMetaDataParser {
    weak var delegate: VideoMetaDataParserDelegate?
    
    func start(for urlStr: String) {
        if urlStr.isEmpty {
            delegate?.parseFailed(err: .urlEmpty)
            return
        }
        
        guard let url = URL(string: urlStr) else {
            delegate?.parseFailed(err: .urlInvalid)
            return
        }
        
        // TODO: refactor using JSONDecoder()
        URLSession.shared.dataTask(with: url) {
            [unowned self] (data, response, error) -> Void in
            let parseResult = VideoMetaDataParseResult()
            if error == nil && data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
                    
                    if let name = json["name"] as? String {
                        parseResult.name = name
                    }
                    
                    if let dateStr = json["date"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "ddMMyyyy"
                        parseResult.date = dateFormatter.date(from: dateStr) ?? Date.distantPast
                    }
                   
                    if let videoSizeStr = json["video_size"] as? String {
                        let sizeList = videoSizeStr.split(separator: "x")
                        if sizeList.count > 1 {
                            let w = Int(sizeList[0]) ?? 0
                            let h = Int(sizeList[1]) ?? 0
                            parseResult.videoSize = w > 0 && h > 0 ? CGSize(width: w, height: h) : .zero
                        }
                    }
                    
                    if let paths = json["paths"] as? Array<Dictionary<String, Any>> {
                        for path in paths {
                            guard let url = path["url"] as? String else {
                                continue
                            }
                            
                            let time = path["time"] as? UInt ?? 0
                            
                            guard let duration = path["duration"] as? UInt else {
                                continue
                            }
                            
                            parseResult.videoFileList.append(time: time, duration: duration, path: url)
                        }
                    }
                    if !parseResult.videoFileList.isEmpty {
                        DispatchQueue.main.async {
                            self.delegate?.parseFinished(result: parseResult)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.delegate?.parseFailed(err: .jsonDataEmpty)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.parseFailed(err: .parseFailed)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.parseFailed(err: .jsonLoadFailed)
                }
            }
        }.resume()
    }
}
