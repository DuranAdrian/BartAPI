//
//  StationDetailViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class StationDetailViewController: UITableViewController {
    let apiKey = "MW9S-E7SL-26DU-VV8V"
    var routesAPIURL: String = ""
    
    var station: Station!
    var stationAbbr: String!
    var stationInfo: StationInfo!
    var routes: [Route]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            self.getStationInfoData()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getRouteData()
        }
        
        self.tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "StationDetailNameTableCell", bundle: nil), forCellReuseIdentifier: "StationDetailNameTableCell")

//        tableView.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getRouteData() {
        let routeAPIURL = "https://api.bart.gov/api/route.aspx?cmd=routes&key=\(apiKey)&json=y"
        guard let routeULR = URL(string: routeAPIURL) else { return }
        
        let task = URLSession.shared.dataTask(with: routeULR, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to routeAPI: \(error)")
                return
            }
            
            ///Connection Successful
            if let data = data {
                self.routes = self.parseRouteJSONData(data: data)
            }
        })
        task.resume()
    }
    
    func parseRouteJSONData(data: Data) -> [Route] {
        let decoder = JSONDecoder()
        var processedRoutes = [Route]()
        do {
            let routeDataStore = try decoder.decode(RouteContainer.self, from: data)
            processedRoutes = routeDataStore.routes
            
        } catch {
            print("Error parsing Route JSON data: \(error)")
        }
        return processedRoutes
    }
    
    func getStationInfoData() {
        let stationInfoAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=\(String(describing: stationAbbr.lowercased()))&key=\(apiKey)&json=y"
        guard let stationURL = URL(string: stationInfoAPIURL) else { return }
        
        let task = URLSession.shared.dataTask(with: stationURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to stationAPI: \(error)")
                return
            }
            
            ///connection succesfull
            if let data = data {
                // Used for debugging
//                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
//                   print(JSONString)
//                }
                self.stationInfo = self.parseStationInfoJSONData(data: data)
                
                OperationQueue.main.addOperation {
                    print("StationInfo data has been parsed, reloding view")
                    self.tableView.reloadData()

                }
            }
            
        })
        task.resume()
    }
    
    func parseStationInfoJSONData(data: Data) -> StationInfo {
        
        let decoder = JSONDecoder()
        var stationInfoItem = [StationInfo]()
        do {
            
            let stationInfoItemData = try decoder.decode(StationInfoContainer.self, from: data)
            stationInfoItem.append(stationInfoItemData.stations)
            return stationInfoItemData.stations
        } catch {
            print("ERROR PARSING STATION INFO JSON DATA: \(error)")
        }
        
//        return stationInfoItem[0]
        return stationInfoItem[0]
    }
    
    func formatRoutes(_ routes: [String]) -> String {
        var routeToFormat = "Routes: "
        routeToFormat.append(routes.map{ $0.replacingOccurrences(of: "ROUTE ", with: "") }.joined(separator: ", "))
        

        return routeToFormat
    }
    
    func findRouteColor(_ route: String) -> String {
        var color: String = "PINK"
        self.routes.forEach { element in
            if element.routeID == route {
                color = element.color
                
            }
        }
        return color
    }
    
    func formatPlatforms(_ platforms: [String]) -> String {
        
        var platformToFormat = (platforms.count == 1) ? "Platform: " : "Platforms: "
    
        platformToFormat.append(platforms.joined(separator: ","))

        return platformToFormat
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //Find if north and south route exists
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        // Map View
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationDetailMapCell.self), for: indexPath) as! StationDetailMapCell
            if let station = stationInfo {
                cell.locationToMap(location: station.location)
            }

            return cell
        // Station Details
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StationDetailNameTableCell", for: indexPath) as! StationDetailNameTableCell
            if let station = stationInfo {
                cell.stationName.text = station.name
                cell.stationAddress.text = station.address
                cell.stationCity.text = [station.city, station.zipcode].joined(separator: ", ")
            }
            return cell
        // North routes and Platform number
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationRoutesTableCell.self), for: indexPath) as! StationRoutesTableCell
            if let cellStation = stationInfo {
                cell.platform.text = formatPlatforms(cellStation.northPlatform)
                cell.routes.text = formatRoutes(cellStation.northRoute)
            }
            cell.compassImage.image = UIImage(systemName: "arrow.up.circle.fill")
            return cell
        // South Routes and Platform number
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationRoutesTableCell.self), for: indexPath) as! StationRoutesTableCell
            if let cellStation = stationInfo {
                cell.platform.text = formatPlatforms(cellStation.southPlatform)
                cell.routes.text = formatRoutes(cellStation.southRoute)
                
            }
            cell.compassImage.image = UIImage(systemName: "arrow.down.circle.fill")
            return cell

        default:
            fatalError("ERROR")
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 215.0
        case 1:
            return 100.0
        default:
            return 43.0
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
