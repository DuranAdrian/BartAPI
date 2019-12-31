//
//  StationRoutesTableCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/19/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class StationRoutesTableCell: UITableViewCell {

    @IBOutlet var routes: UILabel!
    @IBOutlet var compassImage: UIImageView!
    @IBOutlet var platform: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
