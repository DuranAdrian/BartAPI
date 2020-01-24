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
        print("trying message...")
        message = try advisoryContainer.decode(String.self, forKey: .message)
        print(message)
        print("trying date...")
        date = try advisoryContainer.decode(String.self, forKey: .date)
        print(date)
        print("trying time...")
        time = try advisoryContainer.decode(String.self, forKey: .time)
        print(time)
        
        
        // OPEN BSA FOLDER INSIDE OF ROOT
//        let bsaContainer = try advisoryContainer.nestedContainer(keyedBy: BSAKey.self, forKey: .bsa)
        print("trying bsa...")
        bsa = try advisoryContainer.decode([BSA].self, forKey: .bsa)
        print(bsa)
    }
    init() {
        message = ""
        date = ""
        time = ""
        bsa = []
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
        print("TRYING BSA STATION")
        station = try container.decode(String.self, forKey: .station)
        print(station)
        print("BSA STATION COMPLETE")
        
        do {
            print("TRYING BSA DESCRIPTION")
            let descriptionContainer = try container.nestedContainer(keyedBy: descriptionKey.self, forKey: .description)
            description = try descriptionContainer.decode(String.self, forKey: .data)
            print(description)
            print("BSA DESCRIPTION COMPLETE")
        } catch {
            print("Error description")
            description = ""
        }
        

        do {
            print("TRYING SMS_TEXT DESCRIPTION")
            let sms_textDescriptionContainer = try container.nestedContainer(keyedBy: descriptionKey.self, forKey: .sms_text)
            sms_text = try sms_textDescriptionContainer.decode(String.self, forKey: .data)
            print(sms_text)
            print("SMS_TEXT DESCRIPTION COMPLETE")
        } catch {
            print("Error SMS_TEXT description")
            sms_text  = ""
        }
    }
    init() {
        station = ""
        description = ""
        sms_text = ""
    }
}
