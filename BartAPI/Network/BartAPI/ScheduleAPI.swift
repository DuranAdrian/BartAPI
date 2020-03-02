//
//  ScheduleAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class ScheduleAPI: NetworkManager {
    // Fare
    // COMPLETE
    func getFare(from origin: String, to destination: String, completion: @escaping (_ fare: FareContainer?, _ error: String?) -> ()) {
        let fareStringURL = "https://api.bart.gov/api/sched.aspx?cmd=fare&orig=\(origin.lowercased())&dest=\(destination.lowercased())&date=today&key=\(self.apiKey)&json=y"
        guard let fareURL = URL(string: fareStringURL) else {
            completion(nil, "Could not crete fareURL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: fareURL, completionHandler: { (data, response, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            if let data = data {
                do {
                    let parsedFare = try self.decoder.decode(FareContainer.self, from: data)
                    completion(parsedFare, nil)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
            
        })
        task.resume()
    }
}
