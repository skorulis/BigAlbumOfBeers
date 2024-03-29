//  Created by Alexander Skorulis on 1/12/2023.

import Foundation

final class DataAccessService {
    
    private let fileManager = FileManager.default
    
    func fullBeers() throws -> [BeerModel] {
        let data = try Data(contentsOf: URLPaths.full)
        return try JSONDecoder().decode([BeerModel].self, from: data)
    }
    
    func extraEntries() throws -> [String: ExtraEntry] {
        let data = try Data(contentsOf: URLPaths.extra)
        return try JSONDecoder().decode([String: ExtraEntry].self, from: data)
    }
    
    func stats() throws -> [StatsModel] {
        let data = try Data(contentsOf: URLPaths.stats)
        return try JSONDecoder().decode([StatsModel].self, from: data)
    }
    
    func accessTokens() throws -> AccessTokens {
        let data = try Data(contentsOf: URLPaths.stats)
        return try JSONDecoder().decode(AccessTokens.self, from: data)
    }
    
    func rawBeers() throws -> [BeerModel] {
        let data = try Data(contentsOf: URLPaths.raw)
        return try JSONDecoder().decode([BeerModel].self, from: data)
    }
    
    func saveExtra(extra: [String: ExtraEntry]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let outputData = try encoder.encode(extra)
        try outputData.write(to: URLPaths.extra)
    }
}


enum URLPaths {
    static let raw = URL(filePath: "./js/raw.json")
    
    static let extra = URL(filePath: "./js/extra.json")
    
    static let full = URL(filePath: "_data/full.json")
    
    static let stats = URL(filePath: "js/stats.json")
    
    static let accessTokens = URL(filePath: "private/tokens.json")
    
}
