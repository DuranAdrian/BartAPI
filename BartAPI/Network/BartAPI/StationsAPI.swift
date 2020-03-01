//
//  StationsAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class StationsAPI: NetworkManager  {
    // Station List
    public func getStationList() {
        let stationListAPI = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=\(self.apiKey)&json=y"
    }
    
    // Station Info
    public func getStationInfo(stationAbbr: String) {
        let stationInfoAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=\(String(describing: stationAbbr.lowercased()))&key=\(self.apiKey)&json=y"
    }

}
