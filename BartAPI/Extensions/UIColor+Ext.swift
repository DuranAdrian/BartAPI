//
//  UIColor+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/18/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(_ red: Int,_ green: Int,_ blue: Int){
        let redValue = CGFloat(red) / 255.0
        let greenValue = CGFloat(green) / 255.0
        let blueValue = CGFloat(blue) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    
    struct Custom {
        static let annotationBlue = UIColor(41, 168, 171)

    }
}
