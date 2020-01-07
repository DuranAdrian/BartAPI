//
//  TableViewCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/1/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NextTrainCell: UITableViewCell {
    @IBOutlet var routeDirection: UILabel!
    @IBOutlet var destination: UILabel!
    @IBOutlet var timeUntilArrival: UILabel!
    @IBOutlet var routeColorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
