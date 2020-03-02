//
//  NearestStationCell.swift
//  Project1
//
//  Created by Adrian Duran on 2/24/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NearestStationCell: UITableViewCell {
    private var cellLabel: UILabel!
    var stationName: UILabel!
    var stationDistance: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addStation()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        addStation()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addStation()
        selectionStyle = .none
    }
    
    fileprivate func addStation() {
        // Add Nearest BART Station Label
        cellLabel = UILabel()
        cellLabel.text = "Nearest BART Station"
        cellLabel.numberOfLines = 1
        cellLabel.textAlignment = .left
        cellLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellLabel)
        
        // Add stack view
        let labelStack = UIStackView()
        labelStack.axis = .horizontal
        labelStack.alignment = .fill
        labelStack.distribution = .fill
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.setContentHuggingPriority(.init(rawValue: 251.0), for: .horizontal)
        labelStack.setContentHuggingPriority(.init(rawValue: 251.0), for: .vertical)
        labelStack.spacing = 0.0

        addSubview(labelStack)
        
        // Add Station Name
        stationName = UILabel()
        stationName.text = "San Leandro"
        stationName.numberOfLines = 1
        stationName.textAlignment = .left
        stationName.font = UIFont(name: "Arial Rounded MT Bold", size: 21.0)
        stationName.setContentHuggingPriority(.init(rawValue: 250.0), for: .horizontal)
        labelStack.addArrangedSubview(stationName)

        // Add Station Distance
        stationDistance = UILabel()
        stationDistance.text = "1.25 Miles"
        stationDistance.numberOfLines = 1
        stationDistance.font = UIFont(name: "Arial", size: 17.0)
        stationDistance.setContentHuggingPriority(.init(rawValue: 251.0), for: .horizontal)
        labelStack.addArrangedSubview(stationDistance)
        
        NSLayoutConstraint.activate([
            // CELL LABEL
            cellLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            // STACK LABEL
            labelStack.topAnchor.constraint(equalTo: cellLabel.bottomAnchor, constant: 10),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            labelStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

