//
//  StationArrivalsCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/10/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class StationArrivalsCell: UITableViewCell {

    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var destinationName: UILabel!
    @IBOutlet var firstTime: UILabel!
    @IBOutlet var secondTime: UILabel!
    @IBOutlet var thirdTime: UILabel!
    @IBOutlet var routeColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
