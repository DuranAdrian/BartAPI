//
//  DispatchQueue+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/27/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import UIKit

extension DispatchQueue {
    /*
    Simpler way to initate background code
    https://stackoverflow.com/questions/24056205/how-to-use-background-thread-in-swift
    example:
     DispatchQueue.backgroundThread(delay: 2.0, background: {
     // background work
     }, completion: {
     // update main
     })
     */
    static func backgroundThread(delay: Double = 0.0, background:(() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    static func utilityThread(delay: Double = 0.0, background:(() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    static func userInitiatedThread(delay: Double = 0.0, background:(() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    static func userInteractiveThread(delay: Double = 0.0, background:(() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
    static func mainThread(delay: Double = 0.0, firstBlock:(() -> Void)? = nil, secondBlock: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            firstBlock?()
            if let secondBlock = secondBlock {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {secondBlock()})
            }
        }
        
    }



    
}
