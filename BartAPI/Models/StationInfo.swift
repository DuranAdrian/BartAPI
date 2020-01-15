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
    let northPlatform: [String]
    let southPlatform: [String]
    
    
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
        case northPlatform = "north_platforms"
        case southPlatform = "south_platforms"
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
    enum PlatformKey: String, CodingKey {
        case platform
    }
    enum MessageKey: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("ATTEMPING NAME DECODING...")
        name = try container.decode(String.self, forKey: .name)
        print("ATTEMPING ABBREVIATION DECODING...")
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        print("ATTEMPING LATITUDE DECODING...")
        latitude = try container.decode(String.self, forKey: .latitude)
        print("ATTEMPING LONGITUDE DECODING...")
        longitude = try container.decode(String.self, forKey: .longitude)
        print("ATTEMPING ADDRESS DECODING...")
        address = try container.decode(String.self, forKey: .address)
        print("ATTEMPING CITY DECODING...")
        city = try container.decode(String.self, forKey: .city)
        print("ATTEMPING COUNTY DECODING...")
        county = try container.decode(String.self, forKey: .county)
        print("ATTEMPING STATE DECODING...")
        state = try container.decode(String.self, forKey: .state)
        print("ATTEMPING ZIPCODE DECODING...")
        zipcode = try container.decode(String.self, forKey: .zipcode)
        print("ATTEMPING LOCATION DECODING...")
        location = CLLocation(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
        let northRouteContainer = try container.nestedContainer(keyedBy: RouteKey.self, forKey: .northRoute)
        print("ATTEMPING NORTHROUTE DECODING...")
        northRoute = try northRouteContainer.decode([String].self, forKey: .route)
        let southRouteContainer = try container.nestedContainer(keyedBy: RouteKey.self, forKey: .southRoute)
        print("ATTEMPING SOUTHROUTE DECODING...")
        southRoute = try southRouteContainer.decode([String].self, forKey: .route)
        
        do {
            let northPlatformContainer = try container.nestedContainer(keyedBy: PlatformKey.self, forKey: .northPlatform)
            print("ATTEMPING NORTHPLATFORM DECODING...")
            northPlatform = try northPlatformContainer.decode([String].self, forKey: .platform)
        } catch DecodingError.typeMismatch {
            print("ERROR........NORTH PLATFORM TYPE WAS MISMATCHED")
            northPlatform = []
        }

        do {
            let southPlatformContainer = try container.nestedContainer(keyedBy: PlatformKey.self, forKey: .southPlatform)
            print("ATTEMPING SOUTHPLATFORM DECODING...")
            southPlatform = try southPlatformContainer.decode([String].self, forKey: .platform)
        } catch DecodingError.typeMismatch {
            print("ERROR........SOUTH PLATFORM TYPE WAS MISMATCHED")
            southPlatform = []
        }
        
    }
    
    init() {
        name = ""
        abbreviation = ""
        latitude = ""
        longitude = ""
        address = ""
        city = ""
        county = ""
        state = ""
        zipcode = ""
        location = CLLocation()
        
        northRoute = [String]()
        
        southRoute = [String]()
        
        northPlatform = [String]()
        
        southPlatform = [String]()
        
    }
}

struct StationInfoContainer {
    let stations: StationInfo
    let error: String
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
    enum ErrorMessageKey: String, CodingKey {
        case message
    }
    enum Error: String, CodingKey {
        case error
    }
    
    init(from decoder: Decoder) throws {
        print("Attempting container...")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("Attempting rootkey...")
        let rootContainer = try container.nestedContainer(keyedBy: RootKey.self, forKey: .root)
        print("Attempting stationkey...")
//        let stationContainer = try rootContainer.nestedContainer(keyedBy: StationKey.self, forKey: .stations)
        print("TRYING STATIONCONTAINER DECODING...")
        do {
            let stationContainer = try rootContainer.nestedContainer(keyedBy: StationKey.self, forKey: .stations)
            stations = try stationContainer.decode(StationInfo.self, forKey: .station)
        } catch {
            print("Shit hit the fan")
            stations = StationInfo()
        }
        
        do {
            let messageContainer = try container.nestedContainer(keyedBy: ErrorMessageKey.self, forKey: .root)
            let errorContainer = try messageContainer.nestedContainer(keyedBy: Error.self, forKey: .message)
            error =  try errorContainer.decode(String.self, forKey: .error)
        } catch DecodingError.typeMismatch {
            print("No Error Message Found")
            error = ""
        }
        
        //        stations = try stationContainer.decode(StationInfo.self, forKey: .station)
    }
    
}
