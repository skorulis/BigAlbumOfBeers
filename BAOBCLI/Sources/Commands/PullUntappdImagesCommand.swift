//  Created by Alexander Skorulis on 25/2/2023.

import ArgumentParser
import Foundation
import Slugify

final class PullUntappdImagesCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "pull-images",
        abstract: "Pull images from untappd"
    )
    
    func run() async throws {
        let runner = Runner()
        try await runner.run()
    }
    
}

extension PullUntappdImagesCommand {
    struct Runner {
        
        private let urlSession = URLSession(configuration: .default)
        
        
        func run() async throws {
            let data = try Data(contentsOf: URLPaths.full)
            let fileManager = FileManager.default
            let rootURL = URL(filePath: fileManager.currentDirectoryPath)
            
            var beers = try JSONDecoder().decode([BeerModel].self, from: data)
            for i in 0..<beers.count {
                var beer = beers[i]
                let id = beer.name.slugify()
                beer.id = id
                let filename = rootURL.appending(path: "img/list/" + id + ".jpeg")
                if !fileManager.fileExists(at: filename) {
                    print("Downloading image for \(beer.name)")
                    let imageData = try await downloadImage(url: beer.img)
                    try imageData.write(to: filename)
                }
                beers[i] = beer
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let newData = try encoder.encode(beers)
            try newData.write(to: URLPaths.full)
            
            print(beers.count)
        }
        
        func downloadImage(url: String) async throws -> Data {
            guard let url = URL(string: url) else {
                fatalError("Could not covert url \(url)")
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let response = try await urlSession.data(for: urlRequest)
            if let httpResponse = (response.1 as? HTTPURLResponse), httpResponse.statusCode >= 400 {
                fatalError("Invalid status \(httpResponse.statusCode)")
            }
            return response.0
        }
    }
}


