//  Created by Alexander Skorulis on 25/2/2023.

import ArgumentParser
import Foundation

final class UpdateUntappdIDsCommand: AsyncParsableCommand {
    
    @Option
    var sourceFile: String
    
    static let configuration = CommandConfiguration(
        commandName: "update-ids",
        abstract: "Fill in the json file with known IDs"
    )
    
    func run() async throws {
        let accessService = DataAccessService()
        
        let url = URL(filePath: sourceFile)
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([PhotoInfo].self, from: data)
        
        let extractor = FBStringExtractor()
        let entriesParsed = entries.compactMap { info in
            do {
                let result = try extractor.extract(string: info.facebookText)
                return (info, result)
            } catch {
                print(error)
                return nil
            }
        }
        
        var extra = try accessService.extraEntries()
        let entryMap = Dictionary(grouping: entriesParsed) { item in
            return item.1.name
        }.mapValues { $0[0] }
        
        
        for (key, value) in extra {
            if value.untappd.id.isEmpty,
                let entry = entryMap[key],
                let id = entry.0.untappdID
            {
                var mutableValue = value
                mutableValue.untappd.id = "\(id)"
                extra[key] = mutableValue
                print("Filled \(key)")
            }
        }
        
        try accessService.saveExtra(extra: extra)
    }
    
}

