//  Created by Alexander Skorulis on 29/3/2024.

import ArgumentParser
import Foundation

final class GetBreweriesCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "get-breweries",
        abstract: "Get information about breweries"
    )
    
    func run() async throws {
        let accessService = DataAccessService()
        let tokens = try accessService.accessTokens()
        let runner = Runner(accessService: accessService, tokens: tokens)
        try await runner.run()
    }
    
}

extension GetBreweriesCommand {
    struct Runner {
        private let urlSession = URLSession(configuration: .default)
        private let fileManager = FileManager.default
        
        let accessService: DataAccessService
        let tokens: AccessTokens
        
        func run() async throws {
            let beerDir = fileManager.currentDirectoryPath + "/untappd/beer"
            let beerPaths = try fileManager.contentsOfDirectory(atPath: beerDir)
            for filename in beerPaths {
                let url = URL(filePath: "\(beerDir)/\(filename)")
                let data = try Data(contentsOf: url)
                let json = try JSONDecoder().decode(UntappdAPI.GetBeerResponse.self, from: data)
                let breweryId = json.response.beer.brewery.brewery_id
                _ = try await getBrewery(id: breweryId)
            }
        }
        
        private func getBrewery(id: Int) async throws -> UntappdAPI.GetBreweryResponse {
            let filename = "untappd/brewery/\(id).json"
            let fileURL = URL(filePath: fileManager.currentDirectoryPath + "/" + filename)
            if fileManager.fileExists(atPath: filename) {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(UntappdAPI.GetBreweryResponse.self, from: data)
            }
            
            let urlString = "https://api.untappd.com/v4/brewery/info/\(id)?client_id=\(tokens.untappdClientID)&client_secret=\(tokens.untappdClientSecret)"
            let url = URL(string: urlString)!
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let response = try await urlSession.data(for: urlRequest)
            if let httpResponse = (response.1 as? HTTPURLResponse), httpResponse.statusCode >= 400 {
                fatalError("Invalid status \(httpResponse.statusCode)")
            }
            
            print("Save brewery: \(filename)")
            try response.0.write(to: fileURL)
            try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
            return try JSONDecoder().decode(UntappdAPI.GetBreweryResponse.self, from: response.0)
        }
    }
    
    
}

