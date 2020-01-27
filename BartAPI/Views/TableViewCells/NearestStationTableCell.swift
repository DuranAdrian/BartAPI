//
//  NearestStationTableCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/24/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class NearestStationTableCell: UITableViewCell {
    
    @IBOutlet var stationName: UILabel!
    @IBOutlet var stationDistance: UILabel!

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
