//
//  UIButton+Ext.swift
//  Project1
//
//  Created by Adrian Duran on 2/23/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    @objc func pulse() {
        UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform.init(scaleX: 0.85, y: 0.85)
        }, completion: {_ in
            self.transform = CGAffineTransform.identity
        })

    }
}
