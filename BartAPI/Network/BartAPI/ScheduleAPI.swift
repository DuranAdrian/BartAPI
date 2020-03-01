//
//  ScheduleAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class ScheduleAPI: NetworkManager {
    // Arrive By
    func getArriveBy() {
        let apiURL = "http://api.bart.gov/api/sched.aspx?cmd=arrive&orig=ASHB&dest=CIVC&date=now&key=MW9S-E7SL-26DU-VV8V&b=2&a=2&l=1&json=y"
    }
    // Depart By
    
    func getDepartBy() {
        let apiURL = "http://api.bart.gov/api/sched.aspx?cmd=depart&orig=ASHB&dest=CIVC&date=now&key=MW9S-E7SL-26DU-VV8V&b=2&a=2&l=1&json=y"
    }
    
    // Fare
    
    func getFare() {
        let apiKey = "http://api.bart.gov/api/sched.aspx?cmd=fare&orig=12th&dest=embr&date=today&key=MW9S-E7SL-26DU-VV8V&json=y"
    }
}
