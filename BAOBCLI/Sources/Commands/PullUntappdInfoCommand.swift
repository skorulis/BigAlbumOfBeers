//  Created by Alexander Skorulis on 29/3/2024.

import ArgumentParser
import Foundation
import Slugify

final class PullUntappdInfoCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "pull-beer-info",
        abstract: "Pull images from untappd"
    )
    
    func run() async throws {
        let runner = Runner()
        try await runner.run()
    }
}

extension PullUntappdInfoCommand {
    
    struct Runner {
        
        let accessService = DataAccessService()
        
        func run() async throws {
            let tokens = try accessService.accessTokens()
            let beers = try accessService.rawBeers()
            
            var extra = try accessService.extraEntries()
            
            print(beers.count)
        }
    }
    
}
