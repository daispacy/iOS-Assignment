//
//  iOS_AssignmentTests.swift
//  iOS AssignmentTests
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import XCTest
@testable import iOS_Assignment

class iOS_AssignmentTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetUsersFromServer() {
        let expect = expectation(description: "signin")
        
        Request.getUsers(page: 1, pageSize: 50, seed: nil) { (response, error) in
            #if DEBUG
            print("\(String(describing: response?.info?.seed)) \(#function)")
            #endif
            XCTAssert(error == nil, error.debugDescription)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (error) in
            #if DEBUG
            print("\(error.debugDescription) \(#function)")
            #endif
        }
    }
}
