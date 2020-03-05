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
    
    // Filtered Real Time Estimate (directional) of all trains
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
    
    // Single Filtered Real Time Estimate (directional) of North trains
    // COMPLETE
    func getFirstNorthTrain(to origin: String, completion : @escaping (_ estimate: EstimateDeparture?, _ error: String? ) -> ()) {
        getDirectionalEstimateTime(to: origin, dir: "n", completion: { estimate, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let trainContainerEstimates = estimate {
                // Pull first train only
                var nextTrainTime: Int32 = INT32_MAX
                var position = 0
                print("INSIDE GETFIRSTNORTHTRAIN")
                for (index, destination) in trainContainerEstimates.trains[0].estimate.enumerated() {
                    var checkingNextTime: Int32
                    if destination.nextEstimate[0].arrival == "Leaving" {
                        checkingNextTime = 0
                    } else {
                        checkingNextTime = Int32(destination.nextEstimate[0].arrival)!
                    }
                    if checkingNextTime < nextTrainTime {
                        nextTrainTime = checkingNextTime
                        position = index
                    }
                }
                completion(trainContainerEstimates.trains[0].estimate[position],nil)
            }
        })
    }
    
    // Single Filtered Real Time Estimate (directional) of South trains
    // COMPLETE
    func getFirstSouthTrain(to origin: String, completion : @escaping (_ estimate: EstimateDeparture?, _ error: String? ) -> ()) {
        getDirectionalEstimateTime(to: origin, dir: "s", completion: { estimate, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let trainContainerEstimates = estimate {
                // Pull first train only
                var nextTrainTime: Int32 = INT32_MAX
                var position = 0
                print("INSIDE GETFIRSTSOUTHTRAIN")
                for (index, destination) in trainContainerEstimates.trains[0].estimate.enumerated() {
                    var checkingNextTime: Int32
                    if destination.nextEstimate[0].arrival == "Leaving" {
                        checkingNextTime = 0
                    } else {
                        checkingNextTime = Int32(destination.nextEstimate[0].arrival)!
                    }
                    if checkingNextTime < nextTrainTime {
                        nextTrainTime = checkingNextTime
                        position = index
                    }
                }
                completion(trainContainerEstimates.trains[0].estimate[position],nil)
            }
        })
    }
}
