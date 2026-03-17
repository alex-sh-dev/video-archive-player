//
//  VideoMetaDataParser.swift
//  VideoArchivePlayer
//
//  Created by dev on 2/5/26.
//

import Foundation
import Combine

enum ParseError: Error {
    case urlEmpty
    case urlInvalid
    case jsonDataEmpty
    case parseFailed(Error)

    func desc() -> String {
        switch (self) {
        case .parseFailed(let error):
            return error.localizedDescription
        case .urlEmpty:
            return "Json url empty!"
        case .urlInvalid:
            return "Json url invalid!"
        default:
            return "Json data is empty or part is missing!"
        }
    }
}

protocol VideoMetaDataParserDelegate: AnyObject {
    func parseFailed(err: ParseError)
    func parseFinished(result: VideoMetaData)
}

final class VideoMetaDataParser {
    private struct Constants {
        static let kRequestAttemptsCount = 3
    }

    weak var delegate: VideoMetaDataParserDelegate?
    private var _cancellables = Set<AnyCancellable>()

    func start(for urlStr: String) {
        if urlStr.isEmpty {
            self.delegate?.parseFailed(err: .urlEmpty)
            return
        }

        guard let url = URL(string: urlStr) else {
            self.delegate?.parseFailed(err: .urlInvalid)
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .retry(Constants.kRequestAttemptsCount)
            .decode(type: VideoMetaData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.delegate?.parseFailed(err: .parseFailed(error))
                }
            }, receiveValue: {
                [unowned self] result in
                if result.videoFileList.isEmpty {
                    self.delegate?.parseFailed(err: .jsonDataEmpty)
                    return
                }
                self.delegate?.parseFinished(result: result)
            })
            .store(in: &_cancellables)
    }
}
