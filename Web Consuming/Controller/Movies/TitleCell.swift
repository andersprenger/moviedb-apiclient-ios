//
//  TitleCell.swift
//  Web Consuming
//
//  Created by Anderson Renan Paniz Sprenger on 02/07/21.
//

import UIKit

class TitleCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }

}
