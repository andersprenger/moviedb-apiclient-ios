//
//  Movie.swift
//  Web Consuming
//
//  Created by Anderson Sprenger on 01/07/21.
//

import UIKit

struct Movie: Codable {
    
    let title: String?
    let id: Int?
    let genres: [Int?]?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    var image: UIImage {
        let urlString = "https://image.tmdb.org/t/p/w200\(posterPath ?? "/bOFaAXmWWXC3Rbv4u4uM9ZSzRXP.jpg")"
        
        guard let url = URL(string: urlString) else { return UIImage(named: "sample")! }
        guard let data = try? Data(contentsOf: url) else { return UIImage(named: "sample")! }
        guard let image = UIImage(data: data) else { return UIImage(named: "sample")! }
        
        return image
    }
}
