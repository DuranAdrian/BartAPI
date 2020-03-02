//
//  StationsAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class StationsAPI: NetworkManager  {
    // Station List
    // COMPLETE
    public func getStationList(completion: @escaping (_ stations: [Station]?, _ error: String?) -> ()) {
        let urlString = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=\(self.apiKey)&json=y"

        guard let stationListURL = URL(string: urlString) else {
            completion(nil, "Error creating url")
            return
        }

        let task = URLSession.shared.dataTask(with: stationListURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }

            if let data = data {
                do {
                    let parsedStations = try self.decoder.decode(StationContainer.self, from: data)
                    completion(parsedStations.stations, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        })
        task.resume()
    }

    
    // Station Info
    // COMPLETE
    public func getStationInfo(stationAbbr: String, completion: @escaping (_ station: StationInfoContainer?, _ error: String?) -> ()) {
        let stationInfoAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=\( stationAbbr.lowercased())&key=\(self.apiKey)&json=y"
        
        guard let stationURL = URL(string: stationInfoAPIURL) else {
            completion(nil, "Could not create Station Info URL")
            return
        }
        let task = URLSession.shared.dataTask(with: stationURL, completionHandler: { (data, response, error) -> Void in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }

            if let data = data {
                do {
                    let parsedStation = try self.decoder.decode(StationInfoContainer.self, from: data)
                    completion(parsedStation, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        })
        task.resume()
    }

}
