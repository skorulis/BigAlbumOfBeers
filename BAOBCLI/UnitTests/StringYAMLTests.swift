//  Created by Alexander Skorulis on 3/6/2025.

@testable import BAOBCLI
import XCTest

final class StringYAMLTests: XCTestCase {
    
    func test_escapesDoubleQuotes() {
        XCTAssertEqual(
            #"Schlenkerla ("Heller-Bräu" Trum)"#.yamlDoubleQuoted,
            #""Schlenkerla (\"Heller-Bräu\" Trum)""#
        )
    }
    
    func test_apostropheInDoubleQuotesNeedsNoEscape() {
        XCTAssertEqual("O'Brien Beer".yamlDoubleQuoted, #""O'Brien Beer""#)
    }
    
    func test_escapesBackslash() {
        XCTAssertEqual(#"path\to"#.yamlDoubleQuoted, #""path\\to""#)
    }
    
    func test_colonInTitle() {
        XCTAssertEqual(
            "Mountain culture Phase Three: Over Falsity".yamlDoubleQuoted,
            #""Mountain culture Phase Three: Over Falsity""#
        )
    }
}
