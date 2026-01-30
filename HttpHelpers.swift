//
//  HttpHelpers.swift
//  HttpHelpers
//
//  Created by dev on 1/29/26.
//

import Foundation

func existsRemoteFile(url: URL) -> Bool {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    request.timeoutInterval = 1.0
    let semaphore = DispatchSemaphore(value: 0)
    var hasStausCode200 = false
    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            return
        }
        hasStausCode200 = httpResponse.statusCode == 200
        semaphore.signal()
    }
    task.resume()
    // TODO: DispatchTime.distantFuture -> specific timeout?
    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    return hasStausCode200
}
