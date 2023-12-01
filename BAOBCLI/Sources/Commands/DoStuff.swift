import ArgumentParser
import Foundation

struct DoStuff: AsyncParsableCommand {
    
    @Option(help: "Facebook token")
    var fbToken: String
    
    mutating func run() async throws {
        
        let albumFetcher = AlbumScraper(token: fbToken)
        try await albumFetcher.fetchAlbums()
        
        print("Hello worlds")
        let result = try ruby(["scripts/albumscrape"])
        print(result)
    }
    
    @discardableResult // Add to suppress warnings when you don't want/need a result
    func ruby(_ args: [String]) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = args
        task.executableURL = URL(fileURLWithPath: "/Users/alex/.asdf/shims/ruby") //<--updated
        task.standardInput = nil

        try task.run() //<--updated
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}

