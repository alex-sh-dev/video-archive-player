//
//  HttpHelpersTests.swift
//  UnitTests
//
//  Created by dev on 2/5/26.
//

import Foundation

import XCTest

final class HttpHelpersTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testHttpHelpers() {
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        XCTAssertTrue(existsRemoteFile(url: url!))
        let url1 = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mov")
        XCTAssertFalse(existsRemoteFile(url: url1!))
    }
}
