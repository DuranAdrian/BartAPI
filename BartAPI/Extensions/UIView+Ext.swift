//
//  UIView+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/22/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /// Custom function to return screen safe size for use in any UIView.
    func getSafeAreaSize() -> CGRect {
        if #available(iOS 13, *) {
            return safeAreaLayoutGuide.layoutFrame
        }
        return bounds
    }
}
