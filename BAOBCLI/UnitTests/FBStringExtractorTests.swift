//  Created by Alexander Skorulis on 25/2/2023.

@testable import BAOBCLI
import Foundation
import XCTest

final class FBStringExtractorTests: XCTestCase {
    
    private let sut = FBStringExtractor()
    
    func test_basicParsing() throws {
        let name = "Black Sheep Ale. 4.4%\nBlack and average. 2/10"
        
        let details = try sut.extract(string: name)
        
        XCTAssertEqual(details.name, "Black Sheep Ale.")
        XCTAssertEqual(details.pct, "4.4")
        XCTAssertEqual(details.review, "Black and average.")
        XCTAssertEqual(details.rating, "2")
    }
    
    func test_missingPct() throws {
        let name = "Guinness 4.3%\nCannot be rated"
        let details = try sut.extract(string: name)
        
        XCTAssertEqual(details.name, "Guinness")
        XCTAssertEqual(details.pct, "4.3")
        XCTAssertEqual(details.review, "Cannot be rated")
        XCTAssertEqual(details.rating, nil)
    }
    
    func test_longNumbers() throws {
        let name = "Little bang Galacotopus 10.1%\nAlcohol and barley are the only tastes that come through. And I wouldn’t say that it balances out that well. It just doesn’t make me happy 4.5/10"
        
        let details = try sut.extract(string: name)
        
        XCTAssertEqual(details.name, "Little bang Galacotopus")
        XCTAssertEqual(details.pct, "10.1")
        XCTAssertEqual(details.review, "Alcohol and barley are the only tastes that come through. And I wouldn’t say that it balances out that well. It just doesn’t make me happy")
        XCTAssertEqual(details.rating, "4.5")
    }
    
    func test_mountain() throws {
        let name = "Mountain culture Jeffery  11%\nA lot of alcohol and a lot of flavour.  8.5/10"
        let details = try sut.extract(string: name)
        XCTAssertEqual(details.name, "Mountain culture Jeffery")
        XCTAssertEqual(details.pct, "11")
        XCTAssertEqual(details.review, "A lot of alcohol and a lot of flavour.")
        XCTAssertEqual(details.rating, "8.5")
    }
    
}
