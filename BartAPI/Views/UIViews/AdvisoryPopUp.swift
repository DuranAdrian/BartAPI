//
//  AdvisoryPopUp.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/23/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class AdvisoryPopUp: UIView {
    private var messageText: UILabel!
    private var messageHeaderText: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    fileprivate func setUpView() {
        messageHeaderText = UILabel()
        messageHeaderText.text = "ADVISORY:"
        messageHeaderText.font = .preferredFont(forTextStyle: .headline)
        messageHeaderText.textAlignment = .left
        messageHeaderText.textColor = .black
        
        self.addSubview(messageHeaderText)
        
        messageText = UILabel()
        messageText.text = "There is a system wide delay of 10 minutes in all directions due to wet weather."
        messageText.font = .preferredFont(forTextStyle: .caption2)
        messageText.textAlignment = .left
        messageText.textColor = .white
        messageText.numberOfLines = 0
        
        self.addSubview(messageText)
    }
    
    fileprivate func setUpContraints() {
        // MESSAGE HEADER
        messageHeaderText.translatesAutoresizingMaskIntoConstraints = false
        messageHeaderText.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        messageHeaderText.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant:  10).isActive = true
        messageHeaderText.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        messageHeaderText.bottomAnchor.constraint(equalTo: messageText.topAnchor, constant: -5).isActive = true
        
        // ACTUALLY MESSAGE
        messageText.translatesAutoresizingMaskIntoConstraints = false
        
        messageText.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        messageText.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        messageText.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
    }
    
    public func setMessage(message: String) {
        self.messageText.text = message
    }

}
