//
//  RequestTests.swift
//  RequestTests
//
//  Created by Michael Chirico on 12/15/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import XCTest
@testable import Qoperation

extension String {
  func contains(find: String) -> Bool {
    return self.range(of: find) != nil
  }
  func containsIgnoringCase(find: String) -> Bool {
    return self.range(of: find, options: .caseInsensitive) != nil
  }
}

class RequestTests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  class Action: ActionProtocol {
    var expectation: XCTestExpectation?
    var expectation2: XCTestExpectation?
    var count = 0
    var currentResult: String = "" {
      willSet {
          previousResult = currentResult
          count += 1
      }
    }
    var previousResult: String = ""
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func actionAfterResult() {
      print("current: Result: \(currentResult)")
      if let expectation  = expectation {
        expectation.fulfill()
        self.expectation = nil
      } else {
        if let expectation2  = expectation2 {
          expectation2.fulfill()
          self.expectation2 = nil
        }
      }
    }
  }
  
  func testActionOnResult() {
    
    let expectation = self.expectation(description: "Result from url")
    let expectation2 = self.expectation(description: "Result2 from url")
    
    let request = Request()
    let url = "https://www3.septa.org/hackathon/Arrivals/Elkins%20Park"
    
    let action = Action()
    action.expectation = expectation
    
    request.assignAction(action: action)
    request.getURLAction(url: url)

    action.expectation2 = expectation2
    request.getURLAction(url: url)
    
    waitForExpectations(timeout: 15, handler: nil)
    XCTAssert(action.currentResult != "")
    XCTAssert(action.previousResult != "")
    XCTAssert(action.count == 2)
    XCTAssert(action.error == nil)
  }
  
  func testFailActionOnResult() {
    
    let expectation = self.expectation(description: "Result from url")
    let expectation2 = self.expectation(description: "Result2 from url")
    
    let request = Request()
    let url = "https://badUrlCom"
    
    let action = Action()
    action.expectation = expectation
    
    request.assignAction(action: action)
    request.getURLAction(url: url)
    
    action.expectation2 = expectation2
    request.getURLAction(url: url)
    
    waitForExpectations(timeout: 15, handler: nil)
    XCTAssert(action.error != nil)

  }
  
  class Result: ResultProtocol {
    var expectation: XCTestExpectation?
    
    func doneAction() {
      expectation?.fulfill()
    }
  }
  
  func testStationToStation() {
   
    let expectation = self.expectation(description: "")
    
    let request = Request()
    let url = """
https://www3.septa.org/hackathon/NextToArrive/?req1=Suburban%20Station&req2=Elkins%20Park&req3=40
"""
    
    func stationActionTest() -> Bool {
      expectation.fulfill()
      return true
    }
    
    let stationAction = StationAction()
    stationAction.callAfterDone = stationActionTest
    
    let sts = StationToStation()
    sts.assignStationAction(stationAction: stationAction)
    
    request.assignAction(action: stationAction)
    request.getURLAction(url: url)
    
    waitForExpectations(timeout: 15, handler: nil)
    
    sts.parseString(data: sts.urlResults)
    let time = sts.records?.sts[0].orig_arrival_time
    
    XCTAssert((time?.contains(find: ":"))!)
    
  }
  
  func testParse() {
    let request = Request()
    let url = "https://www3.septa.org/hackathon/Arrivals/Elkins%20Park"
    
    request.getURL(url: url)
    let sparse = Sparse()
    sparse.process(stringInput: request.contents)
    
    XCTAssert(sparse.offset! < 65, "No offset")
    
    print(sparse.json)
  }
  
  func testStationToStationGetURL() {
    let p = StationToStation()
    
    let url = """
https://www3.septa.org/hackathon/NextToArrive/?req1=Suburban%20Station&req2=Elkins%20Park&req3=40
"""
    p.getURL(url: url)
    p.parseString(data: p.urlResults)
    
    if p.records!.sts.count < 3 {
      XCTFail("Length Failed")
    }
    
    print(p.records!.sts)
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
