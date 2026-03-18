//
//  ParseError.swift
//  VideoArchivePlayer
//
//  Created by dev on 3/18/26.
//

import Foundation

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
