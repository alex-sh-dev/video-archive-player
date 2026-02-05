//
//  GlobalTests.swift
//  UnitTests
//
//  Created by dev on 2/5/26.
//

import XCTest

private class TestObject {
    var value: Int = 0
    var string: String = "test"
}

final class GlobalTests: XCTestCase {
    
    override func setUpWithError() throws {}
    
    override func tearDownWithError() throws {}
    
    func testUsafePointers() {
        let obj = TestObject()
        obj.value = 10
        let ptr = Unsafe.bridgeRetained(obj: obj)
        let obj1: TestObject = Unsafe.bridge(ptr: ptr)
        XCTAssertNotNil(obj1)
        XCTAssertEqual(obj.value, obj1.value)
        XCTAssertEqual(obj.string, obj1.string)
        XCTAssertNoThrow(Unsafe.destroy(ptr: ptr, for: TestObject.self))
        
        var obj2: TestObject? = TestObject()
        obj2!.value = 20
        let ptr2 = Unsafe.bridge(obj: obj2!)
        XCTAssertNotNil(ptr2)
        let obj3: TestObject = Unsafe.bridge(ptr: ptr2)
        XCTAssertEqual(obj2!.value, obj3.value)
        XCTAssertEqual(obj2!.string, obj3.string)
        obj2 = nil
    }
}
