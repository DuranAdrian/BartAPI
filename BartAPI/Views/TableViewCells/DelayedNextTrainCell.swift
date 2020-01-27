//
//  DelayedNextTrainCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/6/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class DelayedNextTrainCell: UITableViewCell {
    @IBOutlet var routeDirection: UILabel!
    @IBOutlet var destination: UILabel!
    @IBOutlet var timeUntilArrival: UILabel!
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
