//
//  Fare.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/18/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

struct Fare: Codable {
    let amount: String
    let type: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case amount = "@amount"
        case type = "@class"
        case name = "@name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(String.self, forKey: .amount)
        type = try container.decode(String.self, forKey: .type).capitalized
        name = try container.decode(String.self, forKey: .name)
    }
}

struct Fares: Codable {
    let level: String
    let fare: [Fare]
    
    enum CodingKeys: String, CodingKey {
        case level = "@level"
        case fare
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decode(String.self, forKey: .level)
        fare = try container.decode([Fare].self, forKey: .fare)
    }
        
}

struct FareContainer: Codable {
    let origin: String
    let destination: String
    let standardFares: Fares
    
    enum CodingKeys: String, CodingKey {
        case origin
        case destination
        case standardFares = "fares"
    }
    
    enum RootKey: String, CodingKey {
        case root
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fareContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .root)
        origin = try fareContainer.decode(String.self, forKey: .origin)
        destination = try fareContainer.decode(String.self, forKey: .destination)
        standardFares = try fareContainer.decode(Fares.self, forKey: .standardFares)
    }
    
    
}

