//
//  NextTrainCell.swift
//  Project1
//
//  Created by Adrian Duran on 2/25/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NextTrainCell: UITableViewCell {
    
    var routeColorView: UIView!
    var routeDirection: UILabel!
    var destination: UILabel!
    var arrivingInLabel: UILabel!
    var estimatedTimeArrival: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
        selectionStyle = .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        setUpCell()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    fileprivate func setUpCell() {
        // Route color
        routeColorView = UIView()
        routeColorView.backgroundColor = UIColor.red
        addSubview(routeColorView)
        routeColorView.translatesAutoresizingMaskIntoConstraints = false
        
        // Outer Stack
        let outerStack = UIStackView()
        outerStack.axis = .horizontal
        outerStack.alignment = .fill
        outerStack.distribution = .fill
        outerStack.spacing = 0
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.setContentHuggingPriority(.init(252.0), for: .horizontal)
        outerStack.setContentHuggingPriority(.init(250.0), for: .vertical)
        addSubview(outerStack)
        
        // Inner Left Stack
        let innerLeftStack = UIStackView()
        innerLeftStack.axis = .vertical
        innerLeftStack.alignment = .leading
        innerLeftStack.distribution = .fill
        innerLeftStack.spacing = 4
        innerLeftStack.setContentHuggingPriority(.init(251.0), for: .horizontal)
        innerLeftStack.setContentHuggingPriority(.init(250.0), for: .vertical)
        outerStack.addArrangedSubview(innerLeftStack)
        
        // Adding Route Direction
        routeDirection = UILabel()
        routeDirection.text = "Direction"
        routeDirection.font = UIFont.preferredFont(forTextStyle: .caption2)
        routeDirection.textAlignment = .left
        routeDirection.numberOfLines = 1
        routeDirection.setContentHuggingPriority(.init(251.0), for: .horizontal)
        routeDirection.setContentHuggingPriority(.init(250.0), for: .vertical)
        innerLeftStack.addArrangedSubview(routeDirection)
        
        // Adding Route Destination
        destination = UILabel()
        destination.text = "Destination"
        destination.font = UIFont.preferredFont(forTextStyle: .title3)
        destination.textAlignment = .left
        destination.numberOfLines = 1
        destination.setContentHuggingPriority(.init(251.0), for: .horizontal)
        destination.setContentHuggingPriority(.init(251.0), for: .vertical)

        innerLeftStack.addArrangedSubview(destination)

        // Inner Right Stack
        let innerRightStack = UIStackView()
        innerRightStack.axis = .vertical
        innerRightStack.alignment = .trailing
        innerRightStack.distribution = .fill
        innerRightStack.spacing = 4
        innerRightStack.setContentHuggingPriority(.init(251.0), for: .horizontal)
        innerRightStack.setContentHuggingPriority(.init(250.0), for: .vertical)
        outerStack.addArrangedSubview(innerRightStack)
        
        
        // Adding Arrival Label
        arrivingInLabel = UILabel()
        arrivingInLabel.text = "Arriving in"
        arrivingInLabel.textAlignment = .right
        arrivingInLabel.numberOfLines = 1
        arrivingInLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        arrivingInLabel.setContentHuggingPriority(.init(251.0), for: .horizontal)
        arrivingInLabel.setContentHuggingPriority(.init(250.0), for: .vertical)
        innerRightStack.addArrangedSubview(arrivingInLabel)
        
        // Adding EstimatedTimeArrival
        estimatedTimeArrival = UILabel()
        estimatedTimeArrival = UILabel()
        estimatedTimeArrival.text = "Time To Departure"
        estimatedTimeArrival.textAlignment = .right
        estimatedTimeArrival.numberOfLines = 1
        estimatedTimeArrival.font = UIFont.preferredFont(forTextStyle: .title3)
        estimatedTimeArrival.setContentHuggingPriority(.init(251.0), for: .horizontal)
        estimatedTimeArrival.setContentHuggingPriority(.init(251.0), for: .vertical)
        innerRightStack.addArrangedSubview(estimatedTimeArrival)
        
        NSLayoutConstraint.activate([
            // Route Color View
            routeColorView.topAnchor.constraint(equalTo: topAnchor),
            routeColorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            routeColorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            routeColorView.widthAnchor.constraint(equalToConstant: 10.0),
            
            // Outerstack
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: routeColorView.trailingAnchor, constant: 10),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func setArrivalTitle(train: Estimate) -> NSAttributedString {
        // No matter what the outcome is, we need 'Arrival in'
        let stringTitle = "Arrival In"
        let stringAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        var arrivalString = NSAttributedString(string: stringTitle, attributes: stringAttribute)
        
        if train.isDelayed() {
            // Append red delayed text
            let delayedTitleString = "Delayed "
            let delayedAttribute = [NSAttributedString.Key.foregroundColor: UIColor.Custom.errorRed, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
            let delayedString = NSMutableAttributedString(string: delayedTitleString, attributes: delayedAttribute)
            delayedString.append(arrivalString)
            return delayedString
        } else {
            // Normal Mode
            return arrivalString
        }
    }

}
