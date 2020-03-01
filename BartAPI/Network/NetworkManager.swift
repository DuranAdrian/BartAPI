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
    
    // Makes request AND parses if it's able to.
//    func getStationList(completion: @escaping (_ stations: [Station]?, _ error: String?) -> ()) {
//        let urlString = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=\(self.apiKey)&json=y"
//
//        guard let stationListURL = URL(string: urlString) else { completion(nil, "Error creating url")
//            return }
//
//        let task = URLSession.shared.dataTask(with: stationListURL, completionHandler: { (data, response, error) -> Void in
//            if let error = error {
//                completion(nil, error.localizedDescription)
//                return
//            }
//
//            if let data = data {
//                do {
//                    let parsedStations = try self.decoder.decode(StationContainer.self, from: data)
//                    completion(parsedStations.stations, nil)
//                } catch {
//                    completion(nil, error.localizedDescription)
//                }
//            }
//        })
//        task.resume()
//    }

}
