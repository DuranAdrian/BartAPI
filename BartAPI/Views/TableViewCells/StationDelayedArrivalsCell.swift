//
//  StationDelayedArrivalsCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/16/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class StationDelayedArrivalsCell: UITableViewCell {
    
    @IBOutlet weak var delayArrivalTitle: UILabel! {
        didSet {
            delayArrivalTitle.attributedText = setUpTitle(delay: false)
        }
    }
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var destinationName: UILabel!
    @IBOutlet var firstTime: UILabel!
    @IBOutlet var secondTime: UILabel!
    @IBOutlet var thirdTime: UILabel!
    @IBOutlet var routeColorView: UIView!
    
    func setUpTitle(delay: Bool) -> NSAttributedString {
        var normalText = "Arrivals Time"
        let normalAttribute = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        
        if delay {
            let delayText = "Delayed"
            let delayAttribute = [NSAttributedString.Key.foregroundColor: UIColor.Custom.errorRed, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
            let delayString = NSAttributedString(string: delayText, attributes: delayAttribute)
            let combinedString = NSMutableAttributedString()
            normalText = " Arrivals Time"
            let normalString = NSAttributedString(string: normalText, attributes: normalAttribute)
            
            combinedString.append(delayString)
            combinedString.append(normalString)
            
            return combinedString
        }
        
        let normalString = NSAttributedString(string: normalText, attributes: normalAttribute)
        
        return normalString
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
