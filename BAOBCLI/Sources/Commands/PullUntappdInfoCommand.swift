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
        let accessService = DataAccessService()
        let tokens = try! accessService.accessTokens()
        let runner = Runner(accessService: accessService, tokens: tokens)
        try await runner.run()
    }
}

extension PullUntappdInfoCommand {
    
    struct Runner {
        
        let accessService: DataAccessService
        let tokens: AccessTokens
        private let urlSession = URLSession(configuration: .default)
        private let fileManager = FileManager.default
        
        func run() async throws {
            let beers = try accessService.rawBeers()
            let extra = try accessService.extraEntries()
            var newExtra = [String: ExtraEntry]()
            
            for beer in beers {
                if var existing = extra[beer.name] {
                    try await pullDataIfNeeded(name: beer.name, extra: &existing)
                    newExtra[beer.name] = existing
                    continue
                }
                newExtra[beer.name] = .empty
                print("Create new for \(beer.name)")
            }
            
            try await pullMissingFiles(beers: beers, extra: extra)
            
            try accessService.saveExtra(extra: newExtra)
            
            let missingIds = newExtra.filter { $1.untappd.id.isEmpty }
            for extra in missingIds.sorted(by: {$0.key < $1.key}) {
                print("Missing ID: \(extra.key)")
            }
            
            let allIDs: [String] = newExtra.values.compactMap { $0.untappd.id.isEmpty ? nil : $0.untappd.id }
            let duplicates = Set(allIDs.filter { id in  allIDs.filter { $0 == id }.count > 1 })
            for d in duplicates {
                print("Duplicate ID: \(d)")
            }
        }
        
        private func pullMissingFiles(beers: [BeerModel], extra: [String: ExtraEntry]) async throws {
            let missingFiles = beers.filter { beer in
                guard let ex = extra[beer.name] else {
                    return false
                }
                guard !ex.untappd.id.isEmpty else {
                    return false
                }
                return !fileExists(id: ex.untappd.id)
            }
            print("\(missingFiles.count) beers to pull")
            for i in 0..<min(missingFiles.count, 20) {
                let ex = extra[missingFiles[i].name]!
                _ = try await fetchBeerInfo(id: ex.untappd.id).response.beer
            }
        }
        
        private func pullDataIfNeeded(name: String, extra: inout ExtraEntry) async throws {
            if extra.untappd.id.isEmpty || extra.untappd.name != nil {
                return
            }
            
            let beer = try await fetchBeerInfo(id: extra.untappd.id).response.beer
            extra.copyFrom(beer: beer)
        }
        
        private func fileExists(id: String) -> Bool {
            let filename = "untappd/beer/\(id).json"
            return fileManager.fileExists(atPath: filename)
        }
        
        private func fetchBeerInfo(id: String) async throws -> UntappdAPI.GetBeerResponse {
            let filename = "untappd/beer/\(id).json"
            let fileURL = URL(filePath: fileManager.currentDirectoryPath + "/" + filename)
            if fileExists(id: id) {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(UntappdAPI.GetBeerResponse.self, from: data)
            }
            
            let baseURL = "https://api.untappd.com/v4/beer/info"
            let urlString = "\(baseURL)/\(id)?client_id=\(tokens.untappdClientID)&client_secret=\(tokens.untappdClientSecret)"
            let url = URL(string: urlString)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let response = try await urlSession.data(for: urlRequest)
            if let httpResponse = (response.1 as? HTTPURLResponse), httpResponse.statusCode >= 400 {
                fatalError("Invalid status \(httpResponse.statusCode)")
            }
            
            print("Save beer: \(filename)")
            try response.0.write(to: fileURL)
            try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
            return try JSONDecoder().decode(UntappdAPI.GetBeerResponse.self, from: response.0)
        }
    }
    
}
