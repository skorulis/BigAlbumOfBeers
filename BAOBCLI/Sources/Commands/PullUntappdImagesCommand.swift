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
        private let fileManager = FileManager.default
        private let dataAccess = DataAccessService()
        
        func run() async throws {
            var beers = try dataAccess.fullBeers()
            let rootURL = URL(filePath: fileManager.currentDirectoryPath)
            
            for i in 0..<beers.count {
                var beer = beers[i]
                beer.imgPath = "img/list/" + beer.id + ".jpeg"
                beer.filename = "/beer/" + beer.id + ".html"
                let filename = rootURL.appending(path: beer.imgPath!)
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


