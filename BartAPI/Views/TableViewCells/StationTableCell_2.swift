//
//  StationTableCell_2.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/8/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class StationTableCell_2: UITableViewCell {
    
    @IBOutlet var stationName: UILabel!
    @IBOutlet var stationCity: UILabel!
    @IBOutlet var stationAbbr: UILabel!

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
