//
//  NeoTableView.swift
//  Project1
//
//  Created by Adrian Duran on 2/23/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class NeoTableView: UIView {
    let smokeWhite = UIColor.Custom.smokeWhite.cgColor
    let corner: CGFloat = 12.0

    lazy var topLeftShadow = CALayer()
    lazy var bottomRightShadow = CALayer()

    var tableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContainerView()
        setUpTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpContainerView()
        setUpTable()
    }
    
    func setUpContainerView() {
        // Round Corners
        layer.cornerRadius = corner
        layer.borderColor = smokeWhite
        layer.borderWidth = 1.0
        addShadows()
    }
    
    func addShadows() {
        topLeftShadow.backgroundColor = smokeWhite
        topLeftShadow.cornerRadius = corner
        topLeftShadow.shadowRadius = 5.0
        topLeftShadow.shadowColor = UIColor.white.cgColor
        topLeftShadow.shadowOffset = CGSize(width: -3, height: -3)
        topLeftShadow.shadowOpacity = 0.9
        topLeftShadow.masksToBounds = false
        
        bottomRightShadow.backgroundColor = smokeWhite
        bottomRightShadow.cornerRadius = corner
        bottomRightShadow.shadowRadius = 7.5
        bottomRightShadow.shadowOffset = CGSize(width: 5, height: 3)
        bottomRightShadow.shadowOpacity = 0.80
        bottomRightShadow.shadowColor = UIColor.lightGray.cgColor
        bottomRightShadow.masksToBounds = false
    }
    
    func setUpTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 12.0
        tableView.backgroundColor = UIColor.blue
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    //Need to override otherwise view won't appear
    override var intrinsicContentSize: CGSize {
        // For Debugging purposes
//        print(tableView.contentSize)
        
        return tableView.contentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        topLeftShadow.frame = bounds
        layer.insertSublayer(topLeftShadow, at: 0)
        
        bottomRightShadow.frame = bounds
        layer.insertSublayer(bottomRightShadow, at: 0)
        tableView.backgroundColor = UIColor.Custom.smokeWhite
    }

}
