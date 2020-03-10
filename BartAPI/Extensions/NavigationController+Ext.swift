//
//  NavigationController+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/7/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController {
    func makeTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = .white
    }
}
