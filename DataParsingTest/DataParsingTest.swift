//
//  DataParsingTest.swift
//  DataParsingTest
//
//  Created by xinye lei on 16/2/20.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import XCTest
@testable import HStone

class DataParsingTest: XCTestCase {
    
    func test1() {
        let allCardsDic = ParsingCardsData.getCardsForCardSet(ParsingCardsData.CLASSIC)
        let res = ParsingCardsData.getCollectibleCards(allCardsDic!)
        print(res)
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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