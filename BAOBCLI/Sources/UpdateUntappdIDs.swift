//  Created by Alexander Skorulis on 25/2/2023.

import ArgumentParser
import Foundation

final class UpdateUntappdIDs: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "UpdateIDs",
        abstract: "Fill in the json file with known IDs"
    )
    
    func run() async throws {
        print("GO")
    }
}

