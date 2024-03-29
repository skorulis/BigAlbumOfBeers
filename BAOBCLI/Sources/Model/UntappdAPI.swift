//  Created by Alexander Skorulis on 29/3/2024.

import Foundation

enum UntappdAPI {
    
    struct GetBeerResponse: Codable {
        
        let response: Response
        
        struct Response: Codable {
            let beer: Beer
        }
    }
    
    struct GetBreweryResponse: Codable {
        let response: Response
        
        struct Response: Codable {
            let brewery: Brewery
        }
    }
    
    struct Beer: Codable {
        let bid: Int
        let beer_name: String
        let beer_label: String
        let beer_label_hd: String
        let beer_abv: Double
        let beer_ibu: Int?
        let beer_description: String
        let beer_style: String
        let beer_slug: String
        let rating_count: Int
        let rating_score: Double
        
        let brewery: Brewery
        let stats: Stats
        
        var url: String {
            "https://untappd.com/b/\(brewery.brewery_slug)-\(beer_slug)/\(bid)"
        }
        
    }
    
    struct Brewery: Codable {
        let brewery_id: Int
        let brewery_name: String
        let brewery_slug: String
        let brewery_label: String
        let country_name: String
        let brewery_in_production: Int?
        let is_independent: Int?
        let claimed_status: ClaimedStatus?
        let contact: Contact
        let brewery_type: String
        let brewery_type_id: Int?
        let location: Location?
        
    }
    
    struct Stats: Codable {
        let total_count: Int
        let monthly_count: Int
        let total_user_count: Int
        let user_count: Int
    }
    
    struct ClaimedStatus: Codable {
        let is_claimed: Bool
        let claimed_slug: String
        let follow_status: Bool
        let follower_count: Int
        let uid: Int
        let mute_status: String
    }
    
    struct Contact: Codable {
        let twitter: String?
        let facebook: String?
        let instagram: String?
        let url: String?
        let slug: String?
    }
    
    struct Location: Codable {
        let address: String?
        let lat: Double?
        let lng: Double?
    }
    
    
}
