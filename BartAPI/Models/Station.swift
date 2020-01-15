//
//  Stations.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import CoreLocation

struct Station: Codable {
    let name: String
    let abbreviation: String
    let latitude: String
    let longitude: String
    let address: String
    let city: String
    let county: String
    let state: String
    let zipcode: String
    let location: CLLocation
    
    enum CodingKeys: String, CodingKey {
        case name
        case abbreviation = "abbr"
        case latitude = "gtfs_latitude"
        case longitude = "gtfs_longitude"
        case address
        case city
        case county
        case state
        case zipcode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        latitude = try container.decode(String.self, forKey: .latitude)
        longitude = try container.decode(String.self, forKey: .longitude)
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        county = try container.decode(String.self, forKey: .county)
        state = try container.decode(String.self, forKey: .state)
        zipcode = try container.decode(String.self, forKey: .zipcode)
        location = CLLocation(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
    }
    
}

struct StationContainer {
    let stations: [Station]
}

extension StationContainer: Decodable {
    enum CodingKeys: String, CodingKey {
        case root
    }
    
    enum RootKey: String, CodingKey {
        case stations
    }
    
    enum StationKey: String, CodingKey {
        case station
    }
    
    init(from decoder: Decoder) throws {
        print("Trying coding keys...")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("Trying rootkeys...")
        let rootContainer = try container.nestedContainer(keyedBy: RootKey.self, forKey: .root)
        print("Trying stationkeys...")
        let stationContainer = try rootContainer.nestedContainer(keyedBy: StationKey.self, forKey: .stations)
        stations = try stationContainer.decode([Station].self, forKey: .station)
    }
    
}
