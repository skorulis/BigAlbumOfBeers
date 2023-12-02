//  Created by Alexander Skorulis on 1/12/2023.

import Foundation

struct BeerModel: Codable {
    var id: String?
    let name: String
    let desc: String
    let img: String
    let pct: String?
    let link: String
    let date: String
    let score: String?
    let brewery: String?
    
    var imgPath: String {
        "img/list/" + name.slugify() + ".jpeg"
    }
}
