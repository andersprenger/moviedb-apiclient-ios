//
//  DetailsController.swift
//  Web Consuming
//
//  Created by Anderson Renan Paniz Sprenger on 02/07/21.
//

import UIKit

class DetailsController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var tituloFilme: UILabel!
    @IBOutlet weak var generes: UILabel!
    @IBOutlet weak var voteAverage: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    var imageView: UIImage?
    var tituloString: String?
    var generesString: String?
    var voteString: String?
    var overviewString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.img.image = imageView
        self.img.layer.cornerRadius = 10
        
        self.tituloFilme.text = tituloString
        self.generes.text = generesString
        self.voteAverage.text = voteString
        self.overview.text = overviewString
    }
}
