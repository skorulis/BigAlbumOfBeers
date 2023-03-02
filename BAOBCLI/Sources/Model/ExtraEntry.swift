//  Created by Alexander Skorulis on 26/2/2023.

import Foundation

struct ExtraEntry: Codable {
    var untappd: Untappd
    
    struct Untappd: Codable {
        var id: String
        let style: String?
        let IBU: Int?
        let score: Double?
        let brewery: String?
        let country: String?
        let name: String?
        let url: String?
        let breweryId: Int?
        let abv: Double?
        let count: Int?
        let users: Int?

    }
}
