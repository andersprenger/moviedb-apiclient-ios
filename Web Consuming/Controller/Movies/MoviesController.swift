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
    
    enum MovieListType: CaseIterable {
        case favorites, playing
        
        var title: String {
            switch self {
            case .playing:
                return "Now Playing"
            case .favorites:
                return "Popular Movies"
            }
        }
    }
    
    let sections = MovieListType.allCases
    
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
        
        
        
        dbClient.loadPage {
            DispatchQueue.main.async {
                self.moviesTableView.reloadData()
            }
        }
    }
    
    @objc func refresh() {
        dbClient.reload {
            DispatchQueue.main.async {
                self.moviesTableView.reloadData()
            }
        }
        refreshControl?.endRefreshing()
    }
    
    // MARK: -- load data
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sections[section]
        
        switch currentSection {
        case .favorites:
            return dbClient.popularMovies.count
        case .playing:
            return dbClient.nowPlayingMovies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSection = sections[indexPath.section]
        let movie: Movie
        
        switch currentSection {
        case .favorites:
            movie = dbClient.popularMovies[indexPath.row]
            
        case .playing:
            movie = dbClient.nowPlayingMovies[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell") as! MovieCell
        
        cell.title.text = movie.title
        cell.overview.text = movie.overview
        cell.voteAverage.text = String(movie.voteAverage ?? 10)

        let movieId = movie.id
        cell.img.image = dbClient.coverCollection[movieId ?? -1]
        cell.img.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let movieCellHeader = MovieCellHeader()
        let currentSection = sections[section]
        movieCellHeader.titleLabel.text = currentSection.title
        return movieCellHeader
    }
    
    // MARK: -- pagination
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= 10 {
            dbClient.loadPage {
                DispatchQueue.main.async {
                    self.moviesTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: -- show details
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "movies-to-details", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailsController else { fatalError() }
        guard let indexPath = sender as? IndexPath else { fatalError() }
        
        let movie: Movie
        
        switch (sections[indexPath.section])  {
        case .favorites:
            movie = dbClient.popularMovies[indexPath.row]

        case .playing:
            movie = dbClient.nowPlayingMovies[indexPath.row]
            
        }
        
        destination.imageView = dbClient.coverCollection[movie.id!]
        destination.tituloString = movie.title
        destination.generesString = dbClient.getGeneresText(from: movie)
        destination.voteString = String(movie.voteAverage ?? 10)

        destination.overviewString = movie.overview
    }
    
    // MARK: -- load search
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        print(searchString)
        
    // FIXME: -- implement search...
    }
}

