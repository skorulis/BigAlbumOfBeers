//  Created by Alexander Skorulis on 25/2/2023.

import Foundation
import ASKCore

final class AlbumScraper {
    let albumIDs = [
        "10151283325498745",
        "10152534310003745",
        "10154858207913745",
        "10156797308368745",
        "10158912005143745",
    ]
    
    private let token: String
    private let network: HTTPService
    
    init(token: String) {
        self.token = token
        self.network = HTTPService(logger: HTTPLogger())
    }
    
    func fetchAlbums() async throws {
        for albumID in albumIDs {
            
        }
        
        
    }
    
    func fetchAlbum() async throws {
        var images: [Photo] = []
        let req = FacebookRequests.fetchAlbum(token: token, albumId: albumIDs[0])
        let result = try await self.network.execute(request: req)
        
    }
    
}

struct Album: Codable {
    let id: String
    let photos: AlbumPhotos
}

struct AlbumPhotos: Codable {
    let data: [Photo]
    let paging: Paging
}

struct Photo: Codable {
    let link: String
    let id: String
    let name: String
    let images: [PhotoImage]
    
}

struct PhotoImage: Codable {
    let source: String
    let width: Int
    let height: Int
}

struct Paging: Codable {
    let next: String?
}

enum FacebookRequests {
    
    static func fetchAlbum(token: String, albumId: String) -> HTTPJSONRequest<Album> {
        let params: [URLQueryItem] = [
            .init(name: "access_token", value: token),
            .init(name: "fields", value: "photos.limit(150){images,created_time,name,id,link}"),
        ]
        let url = "https://graph.facebook.com/v9.0/\(albumId)"
        var comps = URLComponents(string: url)!
        comps.queryItems = params
        let req = HTTPJSONRequest<Album>(endpoint: comps.string!)
        return req
    }
    
}
