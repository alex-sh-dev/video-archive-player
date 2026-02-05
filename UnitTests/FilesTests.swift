//
//  FilesTests.swift
//  UnitTests
//
//  Created by dev on 2/3/26.
//

import XCTest

final class FilesTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    func testVideoFileInfo() {
        let vfi1 = VideoFileInfo()
        XCTAssertEqual(vfi1.creationTime, 0)
        XCTAssertEqual(vfi1.duration, 0)
        let vfi2 = VideoFileInfo(time: 1770099945, duration: 2)
        XCTAssertEqual(vfi2.duration, 2)
        XCTAssertGreaterThanOrEqual(vfi2.creationTime, 0)
        XCTAssertLessThan(vfi2.creationTime, 86400)
        
        let tz = TimeZone(abbreviation: "GMT+5:00")
        var res = VideoFileInfo.toDailySec(1770058800, timeZone: tz)
        XCTAssertEqual(res.result, 0)
        res = VideoFileInfo.toDailySec(1770102000, timeZone: tz)
        XCTAssertEqual(res.result, 43200)
        res = VideoFileInfo.toDailySec(1770145199, timeZone: tz)
        XCTAssertEqual(res.result, 86399)
    }
    
    func testVideoFileListClass() {
        let list: VideoFileList = VideoFileList()
        XCTAssertEqual(list.count, 0)
        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
        XCTAssertEqual(list.paths.count, 0)
        
        let vfi1: VideoFileInfo = VideoFileInfo(time: 1, duration: 10)
        let vfi2: VideoFileInfo = VideoFileInfo(time: 11, duration: 100)
        let vfi3: VideoFileInfo = VideoFileInfo()
        
        list.append(info: vfi1, path: "path1")
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.first!.info.duration, 10)
        XCTAssertEqual(list.last!.path, "path1")
        XCTAssertEqual(list.last!.info.duration, 10)
        
        list.append(info: vfi2, path: "path2")
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.last!.path, "path2")
        
        XCTAssertEqual(list.count, 2)
    
        list.append(info: vfi3, path: "path3")
        XCTAssertEqual(list.last!.path, "path3")
        XCTAssertEqual(list.last!.info.creationTime, 0)
        
        list.append(time: 20, duration: 20, path: "path4")
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.last!.path, "path4")
        XCTAssertEqual(list.last!.info.duration, 20)
        
        XCTAssertEqual(list.count, 4)
        XCTAssertEqual(list.paths.count, 4)
        XCTAssertEqual(list.paths.first, "path1")
        XCTAssertEqual(list.paths[list.paths.count - 1], "path4")
        
        let item = list[100]
        XCTAssertNil(item)
        XCTAssertEqual(list.count, 4)
        XCTAssertNoThrow(list[100] = (vfi1, "path5"))
        let item1 = list[1]
        XCTAssertNotNil(item1)
        XCTAssertEqual(item1!.path, "path2")
        list[0] = (vfi2, "path6")
        XCTAssertEqual(list[0]!.path, "path6")
        
        list.remove(at: 100)
        XCTAssertEqual(list.count, 4)
        list.remove(at: 0)
        XCTAssertEqual(list.count, 3)
        XCTAssertNotEqual(list.first!.path, "path6")
        XCTAssertEqual(list.first!.path, "path2")
        list.remove(at: 1)
        XCTAssertEqual(list.count, 2)
        XCTAssertNotEqual(list[1]!.path, "path3")
        XCTAssertEqual(list[1]!.path, "path4")
        
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.paths.count, 2)
    }
}
