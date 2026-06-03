//  Created by Alexander Skorulis on 29/12/2024.

import Foundation
import Slugify

extension String {
    
    /// Matches Jekyll `Jekyll::Utils.slugify` / `:title` permalinks (and `customSlugify` in createPosts.rb)
    func slugifySafe() -> String {
        var slug = trimmingCharacters(in: .whitespacesAndNewlines).slugify()
        slug = slug.replacingOccurrences(of: "-.", with: ".")
        slug = slug.replacingOccurrences(of: "---", with: "-")
        slug = slug.replacingOccurrences(of: "--", with: "-")
        slug = slug.replacingOccurrences(of: "Ø", with: "o")
        while slug.hasSuffix("-") {
            slug.removeLast()
        }
        return slug
    }
}
