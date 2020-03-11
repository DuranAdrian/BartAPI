//
//  NeoSegController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/10/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NeoSegController: UISegmentedControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // Common logic goes here
        //self.layer.backgroundColor = UIColor.Custom..cgColor
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)], for: .normal)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
