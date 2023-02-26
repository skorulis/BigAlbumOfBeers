//  Created by Alexander Skorulis on 26/2/2023.

import Foundation

struct ExtraEntry: Codable {
    let untappd: Untappd
    
    struct Untappd: Codable {
        let id: String
    }
}
