//
//  FindRouteButton.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/8/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

@IBDesignable
class FindRouteButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // Common logic goes here
        self.layer.backgroundColor = UIColor.Custom.annotationBlue.cgColor
        self.layer.cornerRadius = 15
        self.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
        self.layer.masksToBounds = true
        
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
