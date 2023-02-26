//  Created by Alexander Skorulis on 25/2/2023.

import Foundation

struct FBStringExtractor {
    
    private let regex = #/(.+?)(\d?\d\.?\d?)%\n(.+?)(\d\.?\d?)\/10/#
    private let noRatingRegex = #/(.+?)(\d?\d\.?\d?)%\n(.*)/#
    
    init() { }
    
    func extract(string: String) throws -> FBStringComponents {
        guard let match = try! regex.firstMatch(in: string) else {
            return try extractNoRating(string: string)
        }
        
        return FBStringComponents(
            name: String(match.output.1).trimmingCharacters(in: .whitespaces),
            review: String(match.output.3).trimmingCharacters(in: .whitespaces),
            pct: String(match.output.2).trimmingCharacters(in: .whitespaces),
            rating: String(match.output.4).trimmingCharacters(in: .whitespaces)
        )
    }
    
    func extractNoRating(string: String) throws -> FBStringComponents {
        guard let match = try! noRatingRegex.firstMatch(in: string) else {
            throw ErrorCases.parseFailure(string)
        }
        return FBStringComponents(
            name: String(match.output.1).trimmingCharacters(in: .whitespaces),
            review: String(match.output.3).trimmingCharacters(in: .whitespaces),
            pct: String(match.output.2).trimmingCharacters(in: .whitespaces),
            rating: nil
        )
    }
    
}

extension FBStringExtractor {
    enum ErrorCases: LocalizedError {
        case parseFailure(String)
        
        var errorDescription: String? {
            switch self {
            case let .parseFailure(string):
                return "Could not parse: \(string)"
            }
        }
    }
}

struct FBStringComponents {
    let name: String
    let review: String
    let pct: String
    let rating: String?
}
