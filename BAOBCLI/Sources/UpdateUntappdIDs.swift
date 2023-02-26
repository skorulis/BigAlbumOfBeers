//  Created by Alexander Skorulis on 25/2/2023.

import ArgumentParser
import Foundation

final class UpdateUntappdIDs: AsyncParsableCommand {
    
    static let extraURL = URL(filePath: "./js/extra.json")
    
    @Option
    var sourceFile: String
    
    static let configuration = CommandConfiguration(
        commandName: "UpdateIDs",
        abstract: "Fill in the json file with known IDs"
    )
    
    func run() async throws {
        print(Self.extraURL)
        let url = URL(filePath: sourceFile)
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([PhotoInfo].self, from: data)
        
        let extractor = FBStringExtractor()
        let extraData = try Data(contentsOf: Self.extraURL)
        let entriesParsed = entries.compactMap { info in
            do {
                let result = try extractor.extract(string: info.facebookText)
                return (info, result)
            } catch {
                print(error)
                return nil
            }
        }
        
        var extra = try JSONDecoder().decode([String: ExtraEntry].self, from: extraData)
        let entryMap = Dictionary(grouping: entriesParsed) { item in
            return item.1.name
        }.mapValues { $0[0] }
        
        
        
        
    }
    
}

