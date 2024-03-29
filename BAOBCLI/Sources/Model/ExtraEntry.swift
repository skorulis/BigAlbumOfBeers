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
        
        static var empty: Untappd {
            .init(
                id: "",
                style: nil,
                IBU: nil,
                score: nil,
                brewery: nil,
                country: nil,
                name: nil,
                url: nil,
                breweryId: nil,
                abv: nil,
                count: nil,
                users: nil
            )
        }
    }
    
    mutating func copyFrom(beer: UntappdAPI.Beer) {
        self.untappd = .init(
            id: "\(beer.bid)",
            style: beer.beer_style,
            IBU: beer.beer_ibu,
            score: beer.rating_score,
            brewery: beer.brewery.brewery_name,
            country: beer.brewery.country_name,
            name: beer.beer_name,
            url: beer.url,
            breweryId: beer.brewery.brewery_id,
            abv: beer.beer_abv,
            count: beer.stats.total_count,
            users: beer.stats.total_user_count
        )
    }
    
    static var empty: ExtraEntry {
        return ExtraEntry(
            untappd: .empty
        )
    }
}
