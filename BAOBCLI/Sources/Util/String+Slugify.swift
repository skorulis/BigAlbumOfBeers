//  Created by Alexander Skorulis on 29/12/2024.

import Foundation
import Slugify

extension String {
    
    func slugifySafe() -> String {
        let partial = self.slugify()
        return partial.replacingOccurrences(of: "---", with: "-")
    }
}
