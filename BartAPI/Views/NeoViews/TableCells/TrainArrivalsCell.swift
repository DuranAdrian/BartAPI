//
//  StationArrivalsCell.swift
//  Project1
//
//  Created by Adrian Duran on 2/25/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class TrainArrivalsCell: UITableViewCell {
    var routeColorView: UIView!
    var delayArrivalTitle: UILabel!
    var directionLabel: UILabel!
    var destinationName: UILabel!
    var firstTime: UILabel!
    var secondTime: UILabel!
    var thirdTime: UILabel!
    
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

    fileprivate func setUpCell() {
        // Route Color
        routeColorView = UIView()
        routeColorView.backgroundColor = UIColor.blue
        routeColorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(routeColorView)
        
        // Outer stack
        let outerStack = UIStackView()
        outerStack.axis = .horizontal
        outerStack.alignment = .center
        outerStack.distribution = .fillEqually
        outerStack.spacing = 0
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)
        
        // inner left stack
        let innerLeftStack = UIStackView()
        innerLeftStack.axis = .vertical
        innerLeftStack.alignment = .fill
        innerLeftStack.distribution = .fill
        innerLeftStack.spacing = 10.0
        outerStack.addArrangedSubview(innerLeftStack)
        
        // Direction label
        directionLabel = UILabel()
        directionLabel.text = "North"
        directionLabel.font = .preferredFont(forTextStyle: .caption1)
        directionLabel.textColor = .darkGray
        innerLeftStack.addArrangedSubview(directionLabel)
        
        // Destination Label
        destinationName = UILabel()
        destinationName.text = "SFO / Airport"
        innerLeftStack.addArrangedSubview(destinationName)
        
        // Inner Right Stack
        let innerRightStack = UIStackView()
        innerRightStack.axis = .vertical
        innerRightStack.alignment = .center
        innerRightStack.distribution = .fill
        innerRightStack.spacing = 10.0
        outerStack.addArrangedSubview(innerRightStack)
        
        // Delayed Arrival title
        delayArrivalTitle = UILabel()
//        delayArrivalTitle.text = "Arriving in"
        delayArrivalTitle.attributedText = setUpTitle(delay: true)
//        delayArrivalTitle.font = .preferredFont(forTextStyle: .caption1)
//        delayArrivalTitle.textColor = .darkGray
        innerRightStack.addArrangedSubview(delayArrivalTitle)
        
        // timeStack
        let timeStack = UIStackView()
        timeStack.axis = .horizontal
        timeStack.alignment = .fill
        timeStack.distribution = .fill
        timeStack.spacing = 10.0
        
        // First Time
        firstTime = UILabel()
        firstTime.text = "Leaving"
        firstTime.font = .preferredFont(forTextStyle: .footnote)
        firstTime.textAlignment = .center
        timeStack.addArrangedSubview(firstTime)
        
        // Second Time
        secondTime = UILabel()
        secondTime.text = "5 Mins"
        secondTime.font = .preferredFont(forTextStyle: .footnote)
        secondTime.textAlignment = .center
        timeStack.addArrangedSubview(secondTime)

        // Third Time
        thirdTime = UILabel()
        thirdTime.text = "15 Mins"
        thirdTime.font = .preferredFont(forTextStyle: .footnote)
        thirdTime.textAlignment = .center
        timeStack.addArrangedSubview(thirdTime)

        innerRightStack.addArrangedSubview(timeStack)
        
        NSLayoutConstraint.activate([
            // Route Color
            routeColorView.topAnchor.constraint(equalTo: topAnchor),
            routeColorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            routeColorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            routeColorView.widthAnchor.constraint(equalToConstant: 10.0),
            
            // Outer stack
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: routeColorView.trailingAnchor, constant: 5),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
