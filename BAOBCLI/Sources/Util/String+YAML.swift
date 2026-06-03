//  Created by Alexander Skorulis on 3/6/2025.

import Foundation

extension String {
    
    /// Value safe for YAML front matter using double-quoted scalars (Jekyll/Liquid).
    var yamlDoubleQuoted: String {
        var escaped = ""
        escaped.reserveCapacity(count + 2)
        for character in self {
            switch character {
            case "\\":
                escaped += "\\\\"
            case "\"":
                escaped += "\\\""
            case "\n":
                escaped += "\\n"
            case "\r":
                escaped += "\\r"
            case "\t":
                escaped += "\\t"
            default:
                escaped.append(character)
            }
        }
        return "\"\(escaped)\""
    }
}
