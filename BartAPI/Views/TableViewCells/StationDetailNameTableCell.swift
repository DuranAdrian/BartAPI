//
//  StationDetailNameTableCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/20/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class StationDetailNameTableCell: UITableViewCell {
    var routeDelegate: mapViewDelegate?
    
    @IBOutlet weak var stationAddress: UILabel!
    @IBOutlet weak var stationCity: UILabel!
    @IBOutlet weak var findRouteButton: UIButton! {
        didSet {
            findRouteButton.target(forAction: #selector(routeButtonPressed), withSender: self)
        }
    }
    
    @IBAction func routeButtonPressed() {
        routeDelegate?.didPressButton()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
