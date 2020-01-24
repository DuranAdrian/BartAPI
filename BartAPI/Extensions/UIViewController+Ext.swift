//
//  UIViewController+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/24/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    
    func changeNavBarColors_Ext() {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            if self.traitCollection.userInterfaceStyle == .dark {
                appearance.backgroundColor = .black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                self.navigationController?.navigationBar.tintColor = .white

            } else {
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

                self.navigationController?.navigationBar.tintColor = .black

            }
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.layoutSubviews()
            self.navigationController?.navigationBar.layoutIfNeeded()
        } else {

            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    func changeTabBarColors_Ext() {
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            
            if self.traitCollection.userInterfaceStyle == .dark {
                appearance.backgroundColor = .black
                self.tabBarController?.tabBar.tintColor = UIColor.Custom.disabledBlue

            } else {
                appearance.backgroundColor = .white
                
                self.tabBarController?.tabBar.tintColor = UIColor.Custom.annotationBlue

            }
            self.tabBarController?.tabBar.standardAppearance = appearance
            self.tabBarController?.tabBar.layoutSubviews()
            self.tabBarController?.tabBar.layoutIfNeeded()
        } else {
            UITabBar.appearance().tintColor = .black
            UITabBar.appearance().barTintColor = .white
            UITabBar.appearance().isTranslucent = false
        }

    }
}
