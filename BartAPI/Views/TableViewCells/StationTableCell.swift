//
//  StationTableCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class StationTableCell: UITableViewCell {
    
    @IBOutlet var stationName: UILabel!
    @IBOutlet var stationCity: UILabel!
    @IBOutlet var stationAbbr: UILabel!
    @IBOutlet var stationAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
