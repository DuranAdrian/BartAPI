//
//  FareCostCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/20/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class FareCostCell: UITableViewCell {
    @IBOutlet weak var fareType: UILabel!
    @IBOutlet weak var cost: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
