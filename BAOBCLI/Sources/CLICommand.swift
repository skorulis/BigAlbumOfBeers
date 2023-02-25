//  Created by Alexander Skorulis on 25/2/2023.

import ArgumentParser
import Foundation

@main
struct CLICommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "cli",
        abstract: "Helpful commands to build the BAOB",
        subcommands: [
            UpdateUntappdIDs.self
        ]
        )
    
}
