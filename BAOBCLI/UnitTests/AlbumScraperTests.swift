//  Created by Alexander Skorulis on 25/2/2023.

@testable import BAOBCLI
import XCTest

final class AlbumScraperTests: XCTestCase {
    
    func test_parsing() {
        let name = "Black Sheep Ale. 4.4%\nBlack and average. 2/10"
        let photo = Photo(
            link: "test",
            id: "123",
            name: name,
            images: []
        )
        
        let details = photo.details
        
        XCTAssertEqual(details.name, "Black Sheep Ale.")
        XCTAssertEqual(details.pct, "4.4%")
        XCTAssertEqual(details.review, "Black and average.")
        XCTAssertEqual(details.rating, "2/10")
    }
    
}
