//
//  Route.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/21/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import Foundation

struct Route: Codable {
    let name: String
    let abbreviation: String
    let routeID: String
    let number: String
    let hexcolor: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case abbreviation = "abbr"
        case routeID
        case number
        case hexcolor
        case color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        routeID = try container.decode(String.self, forKey: .routeID)
        number = try container.decode(String.self, forKey: .number)
        hexcolor = try container.decode(String.self, forKey: .hexcolor)
        color = try container.decode(String.self, forKey: .color)
    }
}

struct RouteContainer {
    let routes: [Route]
}

extension RouteContainer: Decodable {
    enum CodingKeys: String, CodingKey {
        case root
    }
    
    enum RootKey: String, CodingKey {
        case routes
    }
    
    enum RouteKey: String, CodingKey {
        case route
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rootContainer = try container.nestedContainer(keyedBy: RootKey.self, forKey: .root)
        let routeContainer = try rootContainer.nestedContainer(keyedBy: RouteKey.self, forKey: .routes)
        routes = try routeContainer.decode([Route].self, forKey: .route)
    }
}
