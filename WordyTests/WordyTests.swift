//
//  WordyTests.swift
//  WordyTests
//
//  Created by Seth Dillingham on 10/3/2015.
//  Copyright © 2015 Macrobyte Resources. All rights reserved.
//

import XCTest
@testable import Wordy

class WordyTests: XCTestCase {
    
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
    
    func testWorldFieldControllerCreate() {
        let wf = UITextField(frame: CGRectMake(0, 0, 100, 40))
        let fc = WordFieldController(field: wf)
        
        XCTAssertNotNil(fc, "worldFieldController was nil")
    }
    
    func testResultsParser() {
        let wf = UITextField(frame: CGRectMake(0, 0, 100, 40))
        if let fc = WordFieldController(field: wf) {
            let resultString = "{\"totalResults\":2,\"searchResults\":[{\"lexicality\": 0,\"count\": 0,\"word\": \"abcde\"},{\"lexicality\": 0,\"count\": 288402,\"word\": \"abcdef\"},{\"lexicality\": 0,\"count\": 147015,\"word\": \"abcdefs\"}]}"
            let data = resultString.dataUsingEncoding(NSUTF8StringEncoding)
            
            fc.parseJsonResults(data, forWord: "abcde*")
            
            XCTAssert(fc.searchResults.count == 2, "result count \(fc.searchResults.count) should be 2")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
