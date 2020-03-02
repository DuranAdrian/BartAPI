//
//  AdvisoryInfoAPI.swift
//  BartAPI
//
//  Created by Adrian Duran on 2/29/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation

class AdvisoryInfoAPI: NetworkManager {
    // Advisories
    // COMPLETE
    func getAdvisory(completion: @escaping (_ data: Advisory?, _ error: String?) -> ()) {
        let apiURL = "https://api.bart.gov/api/bsa.aspx?cmd=bsa&key=\(self.apiKey)&json=y"
        guard let advisoryURL = URL(string: apiURL) else {
            completion(nil, "Could not create advisory URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: advisoryURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(nil, "Could not connect to ADVISORYAPI: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let advisory = try self.decoder.decode(Advisory.self, from: data)
                    completion(advisory, nil)
                } catch {
                    completion(nil, "Error Parsing JSON \(error)")
                }
            }
        })
        task.resume()
    }
}
