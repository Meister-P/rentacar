//
//  RentacarTests.swift
//  RentacarTests
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import XCTest
@testable import Rentacar

class RentacarTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testIsFuture() {
        let now = Date()
        XCTAssertTrue(!now.isFuture, "Result should show that the date is not in the future")
        
        let nearFuture = NSCalendar.current.date(byAdding: .second, value: 1, to: now)!
        XCTAssertTrue(nearFuture.isFuture, "Result should show that the date is in the future")
        let nearPast = NSCalendar.current.date(byAdding: .second, value: -1, to: now)!
        XCTAssertTrue(!nearPast.isFuture, "Result should show that the date is in the past")
        
        let hourFuture = NSCalendar.current.date(byAdding: .hour, value: 1, to: now)!
        XCTAssertTrue(hourFuture.isFuture, "Result should show that the date is in the future")
        let hourPast = NSCalendar.current.date(byAdding: .hour, value: -1, to: now)!
        XCTAssertTrue(!hourPast.isFuture, "Result should show that the date is in the past")
        
        let dayFuture = NSCalendar.current.date(byAdding: .day, value: 1, to: now)!
        XCTAssertTrue(dayFuture.isFuture, "Result should show that the date is in the future")
        let dayPast = NSCalendar.current.date(byAdding: .day, value: -1, to: now)!
        XCTAssertTrue(!dayPast.isFuture, "Result should show that the date is in the past")
        
        let monthFuture = NSCalendar.current.date(byAdding: .month, value: 1, to: now)!
        XCTAssertTrue(monthFuture.isFuture, "Result should show that the date is in the future")
        let monthPast = NSCalendar.current.date(byAdding: .month, value: -1, to: now)!
        XCTAssertTrue(!monthPast.isFuture, "Result should show that the date is in the past")
        
        let yearFuture = NSCalendar.current.date(byAdding: .year, value: 1, to: now)!
        XCTAssertTrue(yearFuture.isFuture, "Result should show that the date is in the future")
        let yearPast = NSCalendar.current.date(byAdding: .year, value: -1, to: now)!
        XCTAssertTrue(!yearPast.isFuture, "Result should show that the date is in the past")
    }
    
    func testImageDownload() {
        let carsFile = Bundle.main.path(forResource: "Cars", ofType: "plist")!
        let cars = NSDictionary(contentsOfFile: carsFile) as! [String: [String: [String: AnyObject]]]
        
        var firstCarUrl: String!
        
        if let carsDict = cars["cars"] {
            if let firstCarDict = carsDict.values.first {
                firstCarUrl = firstCarDict["thumbnailUrl"] as? String
            }
        }
        
        let name = "Get car url"
        let expectation = self.expectation(description: name)
        let session = URLSession(configuration: .default)
        let downloadImageTask = session.dataTask(with: URL(string: firstCarUrl)!) { data, response, error in
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        downloadImageTask.resume()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "Test \(name) failed, request timed out")
        }
    }

    func testVeriffSessionRequest() {
        let url = URL(string: veriffAPIURL + "/sessions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateString = formatter.string(from: Date())
        
        let json: [String: Any] = ["verification":
            ["person": ["firstName": "Kevin", "lastName": "McCallister"],
             "features": ["selfid"],
             "timestamp": dateString]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue(veriffAPIKey, forHTTPHeaderField: "X-AUTH-CLIENT")
        request.setValue("application/json", forHTTPHeaderField: "CONTENT-TYPE")
        
        let jsonDataString = String(data: jsonData!, encoding: .utf8)! + veriffAPISecret
        let signedString = jsonDataString.sha256()
        print("field - X-SIGNATURE : \(signedString)")
        request.setValue(signedString, forHTTPHeaderField: "X-SIGNATURE")
        
        let name = "Get Veriff user data"
        let expectation = self.expectation(description: name)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            
            var session: VeriffSession?
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    session = try decoder.decode(VeriffSession.self, from: data)
                } catch {
                    print("JSON decode error: \(error)")
                }
                
                if let _ = session {
                    expectation.fulfill()
                }
            }
        }
        
        task.resume()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "Test \(name) failed, request timed out")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

