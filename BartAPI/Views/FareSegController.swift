//
//  FareSegController.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/17/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class FareSegController: UISegmentedControl {
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

}
