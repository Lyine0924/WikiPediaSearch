//
//  WikiPediaSearchTests.swift
//  WikiPediaSearchTests
//
//  Created by Lyine on 2020/04/30.
//  Copyright © 2020 Lyine. All rights reserved.
//

import XCTest
import RxSwift
import RxDataSources
@testable import WikiPediaSearch

class WikiPediaSearchTests: XCTestCase {
    
    var viewModel: MainViewModelType?
    var request: APIRequest?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = MainViewModel()
        request = WikipediaRequest.init(word: "hi")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        if let request = request {
            viewModel?.input.fetchData(request: request)
        }
        
        viewModel?
            .output
            .response
            .asObservable()
            .subscribe {
            }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
