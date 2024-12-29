//  Created by Alexander Skorulis on 30/3/2024.

import Foundation

struct BreweryList: Codable {
    
    var breweries: [UntappdAPI.Brewery]
    
    func with(id: Int) -> UntappdAPI.Brewery? {
        return breweries.first(where: { $0.brewery_id == id})
    }
}
