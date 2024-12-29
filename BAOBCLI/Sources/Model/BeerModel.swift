//  Created by Alexander Skorulis on 1/12/2023.

import Foundation
import Slugify

struct BeerModel: Codable {
    var filename: String?
    var imgPath: String?
    let name: String
    let desc: String
    let img: String
    let pct: String?
    let link: String
    let date: String
    let score: String?
    let brewery: String?
    
    var id: String {
        name.slugifySafe()
    }
    
}
