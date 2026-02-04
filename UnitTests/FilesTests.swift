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
        var vfi1 = VideoFileInfo()
        XCTAssertEqual(vfi1.creationTime, 0)
        XCTAssertEqual(vfi1.duration, 0)
        XCTAssertEqual(vfi1.size.height, 0)
        XCTAssertEqual(vfi1.size.width, 0)
        let vfi2 = VideoFileInfo(creationTime: 1, duration: 2, size: CGSize(width: 3, height: 4))
        XCTAssertEqual(vfi2.creationTime, 1)
        XCTAssertEqual(vfi2.duration, 2)
        XCTAssertEqual(vfi2.size.width, 3)
        XCTAssertEqual(vfi2.size.height, 4)
        
        vfi1.creationTime = 1770099945
        let nct = vfi1.numericalCreationTime()
        XCTAssertTrue(nct.succes)
        XCTAssertGreaterThanOrEqual(nct.result, 0)
        XCTAssertLessThan(nct.result, 86400)
        
        let tz = TimeZone(abbreviation: "GMT+5:00")
        vfi1.creationTime = 1770058800
        var res = vfi1.numericalCreationTime(timeZone: tz)
        XCTAssertEqual(res.result, 0)
        vfi1.creationTime = 1770102000
        res = vfi1.numericalCreationTime(timeZone: tz)
        XCTAssertEqual(res.result, 43200)
        vfi1.creationTime = 1770145199
        res = vfi1.numericalCreationTime(timeZone: tz)
        XCTAssertEqual(res.result, 86399)
    }
    
    func testVideoFileListClass() {
        let list: VideoFileList = VideoFileList()
        XCTAssertEqual(list.count, 0)
        XCTAssertNil(list.first)
        XCTAssertNil(list.last)
        XCTAssertEqual(list.paths.count, 0)
        
        let vfi1: VideoFileInfo = VideoFileInfo(creationTime: 1, duration: 10, size: CGSize(width: 10, height: 10))
        let vfi2: VideoFileInfo = VideoFileInfo(creationTime: 11, duration: 10, size: CGSize(width: 20, height: 20))
        let vfi3: VideoFileInfo = VideoFileInfo()
        
        list.append(info: vfi1, path: "path1")
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.first!.info.creationTime, 1)
        XCTAssertEqual(list.last!.path, "path1")
        XCTAssertEqual(list.last!.info.creationTime, 1)
        
        list.append(info: vfi2, path: "path2")
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.last!.path, "path2")
        
        XCTAssertEqual(list.count, 2)
    
        list.append(info: vfi3, path: "path3")
        XCTAssertEqual(list.last!.path, "path3")
        XCTAssertEqual(list.last!.info.creationTime, 0)
        
        list.append(creationTime: 20, duration: 10, path: "path4", size: .zero)
        XCTAssertEqual(list.first!.path, "path1")
        XCTAssertEqual(list.last!.path, "path4")
        XCTAssertEqual(list.last!.info.creationTime, 20)
        
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
