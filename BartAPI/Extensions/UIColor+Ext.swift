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
    
//    convenience init(red: Int, green: Int, blue: Int) {
//        assert(red >= 0 && red <= 255, "Invalid red component")
//        assert(green >= 0 && green <= 255, "Invalid green component")
//        assert(blue >= 0 && blue <= 255, "Invalid blue component")
//
//        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
//    }

    
    
    struct Custom {
        static let annotationBlue = UIColor(41, 168, 171)
        static let bartRed = UIColor(255, 0, 0)
        static let bartOrange = UIColor(255, 153, 51)
        static let bartBeige = UIColor(213, 207, 163)
        static let bartBlue = UIColor(0, 153, 204)
        static let bartPurple = UIColor(196, 99, 197)
        static let bartGreen = UIColor(51, 153, 51)
        static let bartYellow = UIColor(255, 255, 51)
    }
    
    enum BARTCOLORS: String {
        case RED, YELLOW, BLUE, GREEN, BIEGE, PURPLE, ORANGE
        
        var colors: UIColor {
            switch self {
            case .RED:
                return Custom.bartRed
            case .YELLOW:
                return Custom.bartYellow
            case .BLUE:
                return Custom.bartBlue
            case .GREEN:
                return Custom.bartGreen
            case .BIEGE:
                return Custom.bartBeige
            case .PURPLE:
                return Custom.bartPurple
            case .ORANGE:
                return Custom.bartOrange
            
            }
        }
    }
    
}
