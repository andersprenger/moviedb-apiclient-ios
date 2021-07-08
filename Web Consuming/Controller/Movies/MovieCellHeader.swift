//
//  MovieCellHeader.swift
//  Web Consuming
//
//  Created by Anderson Renan Paniz Sprenger on 08/07/21.
//

import UIKit

class MovieCellHeader: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        commmonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commmonInit()
    }

    private func commmonInit() {
        Bundle.main.loadNibNamed("MovieCellHeader", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
