//
//  NeoButton.swift
//  Project1
//
//  Created by Adrian Duran on 2/24/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NeoButton: UIButton {
    let buttonColor = UIColor.Custom.smokeWhite.cgColor
    let corner: CGFloat = 12.0
    
    lazy var topLeftShadow = CALayer()
    lazy var bottomRightShadow = CALayer()
    
    var originalText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
        showOuterShadows()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
        showOuterShadows()
    }
    
    func setUpButton() {
        setTitleColor(.darkGray, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
        adjustsImageWhenHighlighted = false

        self.addTarget(self, action: #selector(UIButton.pulse), for: .touchUpInside)
        
        layer.backgroundColor = buttonColor
        layer.borderColor = buttonColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 12.0
        layer.masksToBounds = false
    }
    
    func showOuterShadows() {
        topLeftShadow.backgroundColor = buttonColor
        topLeftShadow.borderWidth = 2.0
        topLeftShadow.borderColor = buttonColor
        topLeftShadow.cornerRadius = corner
        topLeftShadow.shadowRadius = 12.0
        topLeftShadow.shadowColor = UIColor.white.cgColor
        topLeftShadow.shadowOffset = CGSize(width: -3, height: -3)
        topLeftShadow.shadowOpacity = 0.9
        topLeftShadow.masksToBounds = false
        
        bottomRightShadow.backgroundColor = buttonColor
        bottomRightShadow.cornerRadius = corner
        bottomRightShadow.shadowRadius = 12.0
        bottomRightShadow.shadowOffset = CGSize(width: 3, height: 3)
        bottomRightShadow.shadowOpacity = 0.9
        bottomRightShadow.shadowColor = UIColor.lightGray.cgColor
        bottomRightShadow.masksToBounds = false
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set layer frames and add insertSubLayers
        topLeftShadow.frame = bounds
        layer.insertSublayer(topLeftShadow, at: 0)
        bottomRightShadow.frame = bounds
        layer.insertSublayer(bottomRightShadow, at: 0)
    }
    
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
        activity.color = .lightGray
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
