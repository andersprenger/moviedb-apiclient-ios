//
//  DBClient.swift
//  Web Consuming
//
//  Created by Anderson Renan Paniz Sprenger on 01/07/21.
//

import UIKit

class DBClient {
    private(set) var nowPlayingMovies: [Movie]
    private(set) var popularMovies: [Movie]
    private(set) var coverCollection: [Int: UIImage] = [:]
    private(set) var genreDictionary: [Int: String] = [:]

    private var pageLoad: Int
    
    private var API: String = "https://api.themoviedb.org/"
    private var API_KEY: String = "a23088f8339f956b04f1b7064ddd50f8"
    
    private var url: URL {
        guard let url = URL(string: "\(API)3/movie/now_playing/?api_key=\(API_KEY)&page=\(pageLoad)") else {
            fatalError()
        }
        return url
    }
    
    init() {
        nowPlayingMovies = []
        popularMovies = []
        pageLoad = 0
        
        loadGenres()
        loadPop()
    }
    
    func loadPage(completionHandler: @escaping () -> ()) {
        pageLoad += 1
        
        print(pageLoad)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { fatalError() }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else { fatalError() }
            guard let dict = json as? [String: Any?] else { fatalError() }
            guard let rawMovies = dict["results"] as? [[String: Any]] else { fatalError() }
            
            var local: [Movie] = []
            
            for m in rawMovies {
                let title = m["title"] as? String
                let id = m["id"] as? Int
                let genres = m["genre_ids"] as? [Int]
                let overview = m["overview"] as? String
                let posterPath = m["poster_path"] as? String
                let voteAverage = m["vote_average"] as? Double
                
                let movie = Movie(title: title, id: id, genres: genres, overview: overview, posterPath: posterPath, voteAverage: voteAverage)
                
                local.append(movie)
            }
            
            self.nowPlayingMovies.append(contentsOf: local)
            completionHandler()
            
            self.loadCovers {
                completionHandler()
            }
        }
        .resume()
    }
    
    private func loadPop() {
        let popularURL = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=a23088f8339f956b04f1b7064ddd50f8")!
        
        URLSession.shared.dataTask(with: popularURL) { data, response, error in
            
            guard let data = data else { fatalError() }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else { fatalError() }
            guard let dict = json as? [String: Any?] else { fatalError() }
            guard let rawMovies = dict["results"] as? [[String: Any]] else { fatalError() }
            
            var local: [Movie] = []
            var count = 0
            
            for m in rawMovies {
                if count > 1 {
                    break
                }
                
                let title = m["title"] as? String
                let id = m["id"] as? Int
                let genres = m["genre_ids"] as? [Int]
                let overview = m["overview"] as? String
                let posterPath = m["poster_path"] as? String
                let voteAverage = m["vote_average"] as? Double
                
                let movie = Movie(title: title, id: id, genres: genres, overview: overview, posterPath: posterPath, voteAverage: voteAverage)
                
                local.append(movie)
                print(movie)
                count += 1
            }
            
            self.popularMovies.append(contentsOf: local)
            print(self.popularMovies)
        }
        .resume()
    }
    
    func reload(completionHandler: @escaping () -> ()) {
        nowPlayingMovies = []
        coverCollection = [:]
        pageLoad = 0
        
        loadPage(completionHandler: completionHandler)
    }
    
    private func loadCovers(completionHandler: @escaping () -> ()) {
        for movie in self.popularMovies {
            if let movieId = movie.id {
                if coverCollection[movieId] == nil {
                    let img = movie.image
                    coverCollection.updateValue(img, forKey: movieId)
                    completionHandler()
                }
            }
        }
        
        for movie in self.nowPlayingMovies {
            if let movieId = movie.id {
                if coverCollection[movieId] == nil {
                    let img = movie.image
                    coverCollection.updateValue(img, forKey: movieId)
                    completionHandler()
                }
            }
        }
    }
    
    private func loadGenres() {
        let genresURL = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=a23088f8339f956b04f1b7064ddd50f8")!
        
        URLSession.shared.dataTask(with: genresURL) { data, response, error in
            
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else { return }
            guard let dict = json as? [String: Any] else { return }
            guard let generes = dict["genres"] as? [[String: Any]] else { return }
            
            for g in generes {
                guard let id = g["id"] as? Int else { continue }
                guard let name = g["name"] as? String else { continue }
                
                self.genreDictionary.updateValue(name, forKey: id)
            }
        }
        .resume()
    }
    
    func getGeneresText(from movie: Movie) -> String {
        var str = ""
        
        guard let genres = movie.genres else { return "nil"}
        
        for g in genres {
            str += genreDictionary[g!] ?? "nil"
            if g != genres.last {
                str += ", "
            }
        }
        
        return str
    }
}
