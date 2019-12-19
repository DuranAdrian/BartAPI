//
//  StationInfo.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/19/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation
import CoreLocation

struct StationInfo: Codable {
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
    let northRoute: [String]
    let southRoute: [String]
    
    
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
        case northRoute = "north_routes"
        case southRoute = "south_routes"
    }
    enum RootKey: String, CodingKey {
        case root
    }
    
    enum StationKey: String, CodingKey {
        case station
    }
    enum RouteKey: String, CodingKey {
        case route
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
        let northRouteContainer = try container.nestedContainer(keyedBy: RouteKey.self, forKey: .northRoute)
        northRoute = try northRouteContainer.decode([String].self, forKey: .route)
        let southRouteContainer = try container.nestedContainer(keyedBy: RouteKey.self, forKey: .southRoute)
        southRoute = try southRouteContainer.decode([String].self, forKey: .route)
    }
}

struct StationInfoContainer {
    let stations: StationInfo
}

extension StationInfoContainer: Decodable {
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rootContainer = try container.nestedContainer(keyedBy: RootKey.self, forKey: .root)
        let stationContainer = try rootContainer.nestedContainer(keyedBy: StationKey.self, forKey: .stations)
        stations = try stationContainer.decode(StationInfo.self, forKey: .station)
    }
}
