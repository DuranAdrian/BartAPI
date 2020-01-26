//
//  Advisory.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/23/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

struct Advisory: Codable {
    let message: String
    let date: String
    let time: String
    let bsa: [BSA]
    
    enum CodingKeys: String, CodingKey {
        case message
        case date
        case time
        case bsa
    }
    
    
    enum RootKey: String, CodingKey {
        case root
    }
    
    init(from decoder: Decoder) throws {
        // OPENS ROOT 'FOLDER'
        let container = try decoder.container(keyedBy: RootKey.self)
        
        let advisoryContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .root)
        message = try advisoryContainer.decode(String.self, forKey: .message)
        date = try advisoryContainer.decode(String.self, forKey: .date)
        time = try advisoryContainer.decode(String.self, forKey: .time)
        
        
        // OPEN BSA FOLDER INSIDE OF ROOT
        bsa = try advisoryContainer.decode([BSA].self, forKey: .bsa)
    }
    init() {
        message = ""
        date = ""
        time = ""
        bsa = []
    }
}

extension Advisory: Equatable {
    static func == (lhs: Advisory, rhs: Advisory) -> Bool {
        return lhs.bsa[0].description == rhs.bsa[0].description
    }
}

struct BSA: Codable {
    let station: String
    let description: String
    let sms_text: String
    
    enum CodingKeys: String, CodingKey {
        case station
        case description
        case sms_text
    }
    
    enum descriptionKey: String, CodingKey {
        case data = "#cdata-section"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        station = try container.decode(String.self, forKey: .station)
        
        do {
            let descriptionContainer = try container.nestedContainer(keyedBy: descriptionKey.self, forKey: .description)
            description = try descriptionContainer.decode(String.self, forKey: .data)
        } catch {
            description = ""
        }
        

        do {
            let sms_textDescriptionContainer = try container.nestedContainer(keyedBy: descriptionKey.self, forKey: .sms_text)
            sms_text = try sms_textDescriptionContainer.decode(String.self, forKey: .data)
        } catch {
            sms_text  = ""
        }
    }
    init() {
        station = ""
        description = ""
        sms_text = ""
    }
}
