//
//  Train.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/2/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

struct Train: Codable {
    let stationName: String
    let abbreviation: String
    let estimate: [EstimateDeparture]
    
    enum CodingKeys: String, CodingKey {
        case stationName = "name"
        case abbreviation = "abbr"
        case estimate = "etd"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationName = try container.decode(String.self, forKey: .stationName)
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        estimate = try container.decode([EstimateDeparture].self, forKey: .estimate)
    }
    
    init() {
        stationName =  ""
        abbreviation = ""
        estimate = [EstimateDeparture]()
    }
}


struct EstimateDeparture: Codable {
    let destination: String
    let abbreviation: String
    let limited: String
    let nextEstimate: [Estimate]
    
    enum CodingKeys: String, CodingKey {
        case destination
        case abbreviation
        case limited
        case nextEstimate = "estimate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        destination = try container.decode(String.self, forKey: .destination)
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        limited = try container.decode(String.self, forKey: .limited)
        nextEstimate = try container.decode([Estimate].self, forKey: .nextEstimate)
    }
    
//    init(newDestination: String? = nil, newAbbreviation: String? = nil, newLimited: String? = nil, newNextEstimate: [Estimate]? = nil) {
//        destination = newDestination!
//        abbreviation = newAbbreviation!
//        limited = newLimited!
//        nextEstimate = newNextEstimate!
//    }

    init() {
        destination = ""
        abbreviation = ""
        limited = ""
        nextEstimate = [Estimate]()
    }
    
}



struct Estimate: Codable {
    let arrival: String
    let platform: String
    let direction: String
    let length: String
    let color: String
    let hexcolor: String
    let bikeFlag: String
    let delay: String

    enum CodingKeys: String, CodingKey {
        case arrival = "minutes"
        case platform
        case direction
        case length
        case color
        case hexcolor
        case bikeFlag = "bikeflag"
        case delay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arrival = try container.decode(String.self, forKey: .arrival)
        platform = try container.decode(String.self, forKey: .platform)
        direction = try container.decode(String.self, forKey: .direction)
        length = try container.decode(String.self, forKey: .length)
        color = try container.decode(String.self, forKey: .color)
        hexcolor = try container.decode(String.self, forKey: .hexcolor)
        bikeFlag = try container.decode(String.self, forKey: .bikeFlag)
        delay = try container.decode(String.self, forKey: .delay)
    }
    
    init() {
        arrival = ""
        platform = ""
        direction = ""
        length = ""
        color = ""
        hexcolor = ""
        bikeFlag = ""
        delay = ""
    }
}

extension Estimate {
    func computeDelayTime() -> Int {
        let secondsToConvert: Double = Double(self.delay)!
        var minutes: Int = 0
        minutes = Int((secondsToConvert/60).rounded(.up))
        return minutes
    }
    
    func isDelayed() -> Bool {
        return !(self.delay == "0")
    }
    
    func isLeavingNow() -> Bool {
        return self.arrival == "Leaving Now"
    }
}

struct TrainContainer {
    let trains: [Train]
}


extension TrainContainer: Decodable {
   enum CodingKeys: String, CodingKey {
        case root
    }
    
    enum StationKey: String, CodingKey {
        case station
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rootContainer = try container.nestedContainer(keyedBy: StationKey.self, forKey: .root)
        trains = try rootContainer.decode([Train].self, forKey: .station)
    }
    
    init() {
        trains = [Train]()
    }
}
