//
//  LoadingButton.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/21/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

class loadingButton: UIButton {
    var originalText: String?
    var activityIndicator: UIActivityIndicatorView!
    
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
    
    @IBInspectable
    let activityColor: UIColor = .lightGray
    
    func showLoading() {
        originalText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        if activityIndicator == nil {
            activityIndicator = createActivityIndicator()
        }
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.color = activityColor
        return activity
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityInButton() {
        let xContraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yContraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraints([xContraint,yContraint])
    }
}
