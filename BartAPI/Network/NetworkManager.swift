//
//  NetworkManager.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
class NetworkManager {
    public let apiKey: String = "MW9S-E7SL-26DU-VV8V"
    public var decoder = JSONDecoder()
    public lazy var stations = StationsAPI()
    public lazy var advisories = AdvisoryInfoAPI()
    public lazy var schedules = ScheduleAPI()
    public lazy var eta = RealTimeInfoAPI()
}
