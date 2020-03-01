//
//  RealTimeInfoAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class RealTimeInfoAPI: NetworkManager{
    // Real Time Estimate
    func getEstimateTime() {
        let apiURL = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=RICH&key=MW9S-E7SL-26DU-VV8V&json=y"
    }
    
    // Filtered Real Time Estimate (directional)
    func getDirectionalEstimateTime() {
        let apiURL = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=19th&dir=n&key=MW9S-E7SL-26DU-VV8V&json=y"
    }
}
