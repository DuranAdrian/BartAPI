//
//  FareCostCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/10/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class FareCostCell: UITableViewCell {
    var fareType: UILabel!
    var cost: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addComponents()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        addComponents()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addComponents()
        selectionStyle = .none
    }
    
    fileprivate func addComponents() {
        // Fare Type
        fareType = UILabel()
        fareType.text = "Fare Type"
        fareType.setContentHuggingPriority(.init(251), for: .horizontal)
        fareType.setContentHuggingPriority(.init(251), for: .vertical)
        fareType.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fareType)
        
        // Cost
        cost = UILabel()
        cost.text = "Cost"
        cost.setContentHuggingPriority(.init(251), for: .horizontal)
        cost.setContentHuggingPriority(.init(251), for: .vertical)
        cost.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cost)

        
        NSLayoutConstraint.activate([
            // Fare Type
            fareType.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            fareType.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Cost
            cost.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            cost.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
