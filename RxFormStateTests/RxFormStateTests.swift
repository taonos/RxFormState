//
//  RxFormStateTests.swift
//  RxFormStateTests
//
//  Created by Hong Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import XCTest
import RxFormState
import RxSwift
import RxTests

class RxFormStateTests: XCTestCase {
    private var observer: TestableObserver<Int>!
    let numbers: Array<Int> = [1, 2, 3, 4]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let scheduler = TestScheduler(initialClock: 0)
        observer = scheduler.createObserver(Int.self)
        
        numbers.toObservable()
            .subscribe(observer)
        
        scheduler.start()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUnwrapFilterNil() {
        XCTAssertFalse(observer.events.contains {event in
            event.value == nil
            })
        
        XCTAssertEqual(
            observer.events.count,
            numbers.count + 1 /* complete event*/
        )
    }
    
    func testUnwrapResultValues() {
        //test elements values and type
        let correctValues = [
            next(0, 1),
            next(0, 2),
            next(0, 3),
            next(0, 4),
            completed(0)
        ]
        
        XCTAssertEqual(observer.events, correctValues)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
