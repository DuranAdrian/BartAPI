//
//  AdvisoryInfoAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class AdvisoryInfo: NetworkManager {
    // Advisories
    func getAdvisory() {
        let apiURL = "http://api.bart.gov/api/bsa.aspx?cmd=bsa&key=MW9S-E7SL-26DU-VV8V&json=y"
    }
    
    // Train Count
    func getTrainCount() {
        let apiURL = "http://api.bart.gov/api/bsa.aspx?cmd=count&key=MW9S-E7SL-26DU-VV8V&json=y"
    }
    
}
