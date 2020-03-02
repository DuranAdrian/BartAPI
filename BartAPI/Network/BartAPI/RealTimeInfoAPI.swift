//
//  RealTimeInfoAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class RealTimeInfoAPI: NetworkManager{
    // Real Time Estimate
    // COMPLETE
    func getEstimateTime(at origin: String, completion: @escaping(_ estimate: TrainContainer?, _ error: String?) -> ()) {
        let estimateTimeURLString = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(origin.lowercased())&key=\(self.apiKey)&json=y"
        guard let estimateTimeURL = URL(string: estimateTimeURLString) else {
            completion(nil, "Could not create estimateTimeURL")
            return
        }

        let task = URLSession.shared.dataTask(with: estimateTimeURL, completionHandler: { (data, response, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let parsedTrains = try self.decoder.decode(TrainContainer.self, from: data)
                    completion(parsedTrains, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }

        })
        task.resume()

    }
    
    // Filtered Real Time Estimate (directional)
    // COMPLETE
    func getDirectionalEstimateTime(to origin: String, dir direction: String, completion: @escaping(_ estimate: TrainContainer?, _ error: String?) -> ()) {
        let apiURL = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(origin.lowercased())&dir=\(direction)&key=\(self.apiKey)&json=y"
        guard let directionalEstimateURL = URL(string: apiURL) else {
            completion(nil, "Could not create directionalEstimateURL")
            return
        }

        let task = URLSession.shared.dataTask(with: directionalEstimateURL, completionHandler: { (data, response, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let parsedTrains = try self.decoder.decode(TrainContainer.self, from: data)
                    completion(parsedTrains, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }

        })
        task.resume()

    }
}
