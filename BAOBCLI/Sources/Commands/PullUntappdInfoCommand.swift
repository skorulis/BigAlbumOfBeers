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
            var extra = try accessService.extraEntries()
            
            for beer in beers {
                if var existing = extra[beer.name] {
                    try await pullDataIfNeeded(name: beer.name, extra: &existing)
                    extra[beer.name] = existing
                    continue
                }
                extra[beer.name] = .empty
                print("Create new for \(beer.name)")
            }
            
            print(beers.count)
        }
        
        private func pullDataIfNeeded(name: String, extra: inout ExtraEntry) async throws {
            if extra.untappd.name != nil || extra.untappd.id.isEmpty {
                return
            }
            let beer = try await fetchBeerInfo(id: extra.untappd.id).response.beer
            extra.copyFrom(beer: beer)
        }
        
        private func fetchBeerInfo(id: String) async throws -> UntappdAPI.GetBeerResponse {
            let filename = "untappd/beer/\(id).json"
            let fileURL = URL(filePath: fileManager.currentDirectoryPath + "/" + filename)
            if fileManager.fileExists(atPath: filename) {
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
