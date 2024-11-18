//  Created by Alexander Skorulis on 1/12/2023.

import ArgumentParser
import Foundation
import Slugify

final class CreatePostsCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "create-posts",
        abstract: "Generate required markdown posts"
    )
    
    func run() async throws {
        // let beerRunner = BeerPostsRunner()
        // try await beerRunner.run()
        
        let breweryRunner = BreweryPostsRunner()
        try await breweryRunner.run()
    }
    
}

// MARK: -

extension CreatePostsCommand {
    struct BreweryPostsRunner {
            
        private let dataAccess = DataAccessService()
        private let fileManager = FileManager.default
        
        func run() async throws {
            // try cleanOldData()
            try await writeBreweryPosts()
        }
        
        func cleanOldData() throws {
            let rootURL = URL(filePath: fileManager.currentDirectoryPath)
            let breweryPath = rootURL.appending(path: "_posts/brewery")
            if fileManager.fileExists(at: breweryPath) {
                try fileManager.removeItem(at: breweryPath)
            }
            try fileManager.createDirectory(at: breweryPath, withIntermediateDirectories: true)
        }
        
        func writeBreweryPosts() async throws {
            // let beers = try dataAccess.fullBeers()
            // let breweries = Set(beers.map { $0.brewery })
            let breweries = try dataAccess.breweryList()
            for brewery in breweries.breweries {
                print(brewery.brewery_name)
                try await writeBrewery(brewery: brewery)
            }
        }
        
        func writeBrewery(brewery: UntappdAPI.Brewery) async throws {
            let filename = "_posts/brewery/2016-11-09-" + brewery.brewery_name.slugify() + ".md"
            let url = "https://untappd.com/w/\(brewery.brewery_slug)/\(brewery.brewery_id)"
            
            var output = """
            ---
            layout: brewery
            filename: \(filename)
            title: "\(brewery.brewery_name)"
            permalink: /brewery/:title.html
            breweryURL: "\(url)"
            """
            
            if let instagram = brewery.contact.instagram {
                output += "\ninstagram: '\(instagram)'"
            }
            if let facebook = brewery.contact.facebook {
                output += "\nfacebook: '\(facebook)'"
            }
            if let facebook = brewery.contact.twitter {
                output += "\ntwitter: '\(twitter)'"
            }
            output += "---\n"
            try Data(output.utf8).write(to: URL(filePath: filename))
        }
        
    }
    
}

// MARK: -

extension CreatePostsCommand {
    struct BeerPostsRunner {
        
        private let dataAccess = DataAccessService()
        private let fileManager = FileManager.default
        
        func run() async throws {
            try cleanOldData()
            try await writeBeerPosts()
        }
        
        func cleanOldData() throws {
            let rootURL = URL(filePath: fileManager.currentDirectoryPath)
            let beerPath = rootURL.appending(path: "_posts/beer")
            if fileManager.fileExists(at: beerPath) {
                try fileManager.removeItem(at: beerPath)
            }
            try fileManager.createDirectory(at: beerPath, withIntermediateDirectories: true)
        }
        
        func writeBeerPosts() async throws {
            let beers = try dataAccess.fullBeers()
            let extraData = try dataAccess.extraEntries()
            print("Creating \(beers.count) beer posts")
            for beer in beers {
                let extra = extraData[beer.name]
                try await writeBeer(beer: beer, extra: extra)
            }
        }
        
        func writeBeer(beer: BeerModel, extra: ExtraEntry?) async throws {
            let filename = "_posts/beer/2016-11-09-" + beer.name.slugify() + ".md"
            
            var output = """
            ---
            layout: beer
            filename: \(filename)
            title: \(beer.name)
            category: beer
            score: \(beer.score ?? "")
            beer-date: "\(beer.date)"
            desc: "\(beer.desc)"
            permalink: /beer/:title.html
            img: /\(beer.imgPath!)
            """
            
            if let untappdURL = extra?.untappd.url {
                output += "untappd: \"\(untappdURL)\"\n"
            }
            if let country = extra?.untappd.country {
                output += "country: \"\(country)\"\n"
            }
            if let brewery = extra?.untappd.brewery {
                let breweryURL = "/brewery/\(brewery.slugify()).html"
                output += "brewery: \"\(brewery)\"\n"
                output += "breweryURL: \"\(breweryURL)\"\n"
            }
            if let style = extra?.untappd.style {
                output += "style: \"\(style)\"\n"
            }
            output += "---\n"
            
            try Data(output.utf8).write(to: URL(filePath: filename))
        }
    }
}
