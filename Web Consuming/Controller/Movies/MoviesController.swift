//
//  MoviesController.swift
//  Web Consuming
//
//  Created by Anderson Renan Paniz Sprenger on 01/07/21.
//

import UIKit

class MoviesController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    let dbClient = DBClient()
    
    var searchController: UISearchController?
    var refreshControl: UIRefreshControl?
    
    enum MovieListType {
        case playing, favorites
    }
    
    var selected: (type: MovieListType, n: Int)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController()
        self.navigationItem.searchController = searchController
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        moviesTableView.addSubview(refreshControl!)
        
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        moviesTableView.separatorStyle = .none
        
        dbClient.loadPage()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.moviesTableView.reloadData()
        }
    }
    
    @objc func refresh() {
        dbClient.reload()
        moviesTableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // MARK: -- load data
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dbClient.nowPlayingMovies.count + 4 // 2 titles & 2 popular movies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "title-cell") as! TitleCell
            
            cell.title.text = "Popular Movies"
            
            return cell
            
        case 1...2:
            let n = indexPath.row - 1
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell") as! MovieCell
            
            if n > dbClient.popularMovies.count {
                return cell
            }
            
            cell.title.text = dbClient.popularMovies[n].title
            cell.overview.text = dbClient.popularMovies[n].overview
            cell.voteAverage.text = String(dbClient.popularMovies[n].voteAverage ?? 10)

            let movieId = dbClient.popularMovies[n].id
            cell.img.image = dbClient.coverCollection[movieId ?? -1]
            cell.img.layer.cornerRadius = 10
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "title-cell") as! TitleCell
            
            cell.title.text = "Now Playing"
            
            return cell
            
        case 4...:
            let n = indexPath.row - 4
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell") as! MovieCell
            
            cell.title.text = dbClient.nowPlayingMovies[n].title
            cell.overview.text = dbClient.nowPlayingMovies[n].overview
            cell.voteAverage.text = String(dbClient.nowPlayingMovies[n].voteAverage ?? 10)
            
            let movieId = dbClient.nowPlayingMovies[n].id
            cell.img.image = dbClient.coverCollection[movieId ?? -1]
            cell.img.layer.cornerRadius = 10
            
            return cell
        default:
            fatalError()
        }
    }
    
    // MARK: -- extra feature: pagination
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dbClient.loadPage()
        moviesTableView.reloadData()
    }
    
    // MARK: -- show details
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1...2:
            selected = (.favorites, indexPath.row - 1)
            performSegue(withIdentifier: "movies-to-details", sender: indexPath.row)
            
        case 4...:
            selected = (.playing, indexPath.row - 4)
            performSegue(withIdentifier: "movies-to-details", sender: indexPath.row)

        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailsController else { return }
        guard let n = selected?.n else { return }

        if selected?.type == .favorites {
            destination.imageView = dbClient.coverCollection[dbClient.popularMovies[n].id!]
            destination.tituloString = dbClient.popularMovies[n].title
            destination.generesString = dbClient.getGeneresText(from: dbClient.popularMovies[n])
            destination.voteString = String(dbClient.popularMovies[n].voteAverage ?? 10)

            destination.overviewString = dbClient.popularMovies[n].overview
        } else {
            destination.imageView = dbClient.coverCollection[dbClient.nowPlayingMovies[n].id!]
            destination.tituloString = dbClient.nowPlayingMovies[n].title
            destination.generesString = dbClient.getGeneresText(from: dbClient.nowPlayingMovies[n])
            destination.voteString = String(dbClient.nowPlayingMovies[n].voteAverage ?? 10)

            destination.overviewString = dbClient.nowPlayingMovies[n].overview
        }
    }
    
    // MARK: -- load search
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        print(searchString)
        
    // FIXME: -- implement search...
    }
}

