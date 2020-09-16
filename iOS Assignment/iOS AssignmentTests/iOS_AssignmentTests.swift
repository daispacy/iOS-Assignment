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
        let expect = expectation(description: "\(#function)")
        
        Request.getUsers(page: 1, pageSize: 50, seed: nil) { (response, error) in
            #if DEBUG
            print("\(String(describing: response?.results?.compactMap({$0.gender}))) \(#function)")
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
    
    func testAddUserToCoreData() {
        
        let jsonString = "{\"id\":{\"name\":\"PPS\",\"value\":\"9659131T\"},\"nat\":\"IE\",\"cell\":\"081-895-2455\",\"phone\":\"061-203-9676\",\"login\":{\"sha256\":\"cf3e64efa2d9ed56d8431421a3d4b39bc5a1ff08faa5cf2b65e9c80ef2194125\",\"password\":\"troll\",\"md5\":\"da90fa39cb0ae5cfe0b3cb0bdd1dd418\",\"uuid\":\"5fd71f72-5db6-4a5f-a5e7-09914d305fab\",\"username\":\"heavybear642\",\"sha1\":\"ea37ccd99a0ba82d91e6dcbaed81bd4b396ae52d\",\"salt\":\"2UyQt7Pt\"},\"dob\":{\"date\":\"1977-01-11T04:00:38.750Z\",\"age\":43},\"registered\":{\"date\":\"2004-01-07T10:12:09.159Z\",\"age\":16},\"picture\":{\"large\":\"https:\\/\\/randomuser.me\\/api\\/portraits\\/women\\/26.jpg\",\"thumbnail\":\"https:\\/\\/randomuser.me\\/api\\/portraits\\/thumb\\/women\\/26.jpg\",\"medium\":\"https:\\/\\/randomuser.me\\/api\\/portraits\\/med\\/women\\/26.jpg\"},\"location\":{\"street\":{\"number\":1130,\"name\":\"Westmoreland Street\"},\"city\":\"Kildare\",\"country\":\"Ireland\",\"postcode\":38957,\"timezone\":{\"description\":\"Western Europe Time, London, Lisbon, Casablanca\",\"offset\":\"0:00\"},\"coordinates\":{\"longitude\":\"88.6180\",\"latitude\":\"21.0538\"},\"state\":\"Cork City\"},\"email\":\"dai.pham@gmail.com\",\"gender\":\"female\",\"name\":{\"title\":\"Ms\",\"first\":\"Ellie\",\"last\":\"Wheeler\"}}"
        
        do {
            let user = try User.init(jsonString)
            let expect = expectation(description: "\(#function)")
            UserDO.save(user: user) { (error) in
                XCTAssert(error == nil, error.debugDescription)
                
                expect.fulfill()
            }
            
            waitForExpectations(timeout: 60) { (error) in
                #if DEBUG
                print("\(error.debugDescription) \(#function)")
                #endif
            }
        } catch let err {
            XCTAssert(false, err.localizedDescription)
        }
        
    }
    
    func testGetAllFavoriteUsers() {
        let expect = expectation(description: "\(#function)")
        UserDO.getFavouriteUsers { (users) in
            #if DEBUG
            print("\(users.compactMap({$0.email})) \(#function)")
            #endif
            XCTAssert(users.count > 0, "no user")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (error) in
            #if DEBUG
            print("\(error.debugDescription) \(#function)")
            #endif
        }
    }
    
    func testRemoveAllFavoriteUsers() {
        let expect = expectation(description: "\(#function)")
        UserDO.getFavouriteUsers { (users) in
            #if DEBUG
            print("\(users.compactMap({$0.email})) \(#function)")
            #endif
            let group = DispatchGroup()
            
            users.forEach { (user) in
                group.enter()
                UserDO.clearData(email: user.email) { error in
                    XCTAssert(error == nil, error.debugDescription)
                    group.leave()
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 60) { (error) in
            #if DEBUG
            print("\(error.debugDescription) \(#function)")
            #endif
        }
    }
}
