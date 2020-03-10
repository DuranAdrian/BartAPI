//
//  StationListCell.swift
//  Project1
//
//  Created by Adrian Duran on 2/25/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class StationListCell: UITableViewCell {
    
    var stationName: UILabel!
    var stationCity: UILabel!
    var stationAbbr: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        setUpCell()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    fileprivate func setUpCell(){
        backgroundColor = UIColor.Custom.smokeWhite
        // Station Name
        stationName = UILabel()
        stationName.text = "24th St Mission"
        stationName.font = UIFont.preferredFont(forTextStyle: .headline)
        stationName.numberOfLines = 1
        stationName.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stationName)
        
        // Station City
        stationCity = UILabel()
        stationCity.text = "San Francisco"
        stationCity.font = UIFont.preferredFont(forTextStyle: .caption1)
        stationCity.numberOfLines = 1
        stationCity.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stationCity)

        // Station Abbreviation
        stationAbbr = UILabel()
        stationAbbr.text = "24th"
        stationAbbr.font = UIFont.preferredFont(forTextStyle: .headline)
        stationAbbr.numberOfLines = 1
        stationAbbr.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stationAbbr)
        
        NSLayoutConstraint.activate([
            // Station Name
            stationName.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stationName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            
            // Station City
            stationCity.topAnchor.constraint(equalTo: stationName.bottomAnchor, constant: 5),
            stationCity.leadingAnchor.constraint(equalTo: stationName.leadingAnchor),
            
            // Station Abbreviation
            stationAbbr.topAnchor.constraint(equalTo: stationName.topAnchor),
            stationAbbr.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
            
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
