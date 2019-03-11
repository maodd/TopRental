//
//  TopRentalTests.swift
//  TopRentalTests
//
//  Created by Frank Mao on 2019-01-12.
//  Copyright © 2019 mazoic. All rights reserved.
//

import XCTest


@testable import TopRental

class TopRentalTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchingRentals() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expectation = XCTestExpectation(description: "Fetch rentals")
        
        
        let url = URL(string: "https://parseapi.back4app.com/classes/Rental")
        
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.setValue("SQWySNZPTGoAxhrktbHusVIjX6u0JVzkCaq6P3h1", forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue("QeHdOrrHRjMIPqTILLaFWs4GqWtsO9BjTYm7xv1m", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                XCTFail("No data was downloaded.")
                return }
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            
            
            
            
            do {
                //create decodable object from data
                let decodedObject = try JSONDecoder().decode(ParseResponse.self, from: data)
                print(decodedObject)
            } catch let error {
                print("json decoder error, \(error.localizedDescription)")
            }
            
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
            
        }
        
        task.resume()
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
        }
        
    }
    
    struct ParseResponse: Decodable {
        let results     : [Rental]

    }
    
    struct Rental : Decodable {
        let objectId : String
        let address  : String
        let status   : Int
    }
 

}
