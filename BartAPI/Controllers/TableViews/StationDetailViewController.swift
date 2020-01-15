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
    var allTrains: [EstimateDeparture]!
    var NorthTrains: [EstimateDeparture]! = []
    var SouthTrains: [EstimateDeparture]! = []
    var platformsAndTrains: [Int: [EstimateDeparture]]! = [:]
    var routes: [Route]!
    var successFullDataPull: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.userInitiatedThread(delay: 1.0, background: {
            self.getStationInfoData()
        }, completion: {
            DispatchQueue.userInitiatedThread(delay: 1.0, background: {
                self.getRouteData()
                self.getTrainData()
            }, completion: {
                self.tableView.beginUpdates()
                self.successFullDataPull = true
                self.tableView.insertSections(IndexSet(self.platformsAndTrains.keys), with: .fade)
                self.tableView.reloadData()
                self.tableView.endUpdates()
            })
            
        })
        setUpTableView()
        setUpNavBar()
    }
    
    func setUpTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 215.0
        tableView.register(UINib(nibName: "StationDetailNameTableCell", bundle: nil), forCellReuseIdentifier: "StationDetailNameTableCell")
        tableView.register(UINib(nibName: "StationArrivalsCell", bundle: nil), forCellReuseIdentifier: "StationArrivalsCell")
    }
    
    func setUpNavBar(){
        self.navigationController!.navigationBar.prefersLargeTitles = true
        guard let title = station?.name, #available(iOS 11.0, *) else { return }

        let maxWidth = UIScreen.main.bounds.size.width - 60
        var fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        var width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width

        while width > maxWidth {
          fontSize -= 1
            width = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]).width
        }

        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)
        ]
        
        navigationItem.title = title

    }
    
    // ROUTE DATA
    
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
    
    // STATION INFO DATA
    
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
            return stationInfoItem[0]
        }
    }
    
    // TRAIN DATA
    func getTrainData() {
        let filteredTrainAPIUrl = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(String(describing: self.station!.abbreviation.lowercased()))&key=\(apiKey)&json=y"

        guard let trainURL = URL(string: filteredTrainAPIUrl) else { print("HAD TO RETURN FROM TRAINURL"); return }
            
        let task = URLSession.shared.dataTask(with: trainURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to filteredTrainAPIUrl: \(error)")
                return
            }
            
            ///connection succesfull
            if let data = data {
                print("Success")
                let mytrains = self.parseTrainJSONData(data: data)
            }
//
        })
        task.resume()
    }
    
    func parseTrainJSONData(data: Data) -> [Train] {
        var parsedTrains = [Train]()
        let decoder = JSONDecoder()
        
        do {
            let trainDataStore = try decoder.decode(TrainContainer.self, from: data)
            parsedTrains = trainDataStore.trains
            self.setUpTrains(parsedTrains)
        } catch {
            print("Error parsing Train JSON Data: \(error)")
            
        }
        
        return parsedTrains
    }
    
    func setUpTrains(_ trainList: [Train]) {
        print("Attempting to set up trains with count: \(trainList.count)")
        print("Number of estimate: \(trainList[0].estimate.count)")
        print(trainList)
        for train in trainList[0].estimate {
            if let _ = platformsAndTrains[Int(train.nextEstimate[0].platform)!] {
                // key exist, only append to array
                platformsAndTrains[Int(train.nextEstimate[0].platform)!]?.append(train)
            } else {
                // key does not exist, add key, start new array
                platformsAndTrains[Int(train.nextEstimate[0].platform)!] = [train]
            }
        }
    }
    
    // FORMATTING FUNCTIONS
    
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
    
    func formatArrivalTime(_ time: String) -> String {
        if time == "leaving" {
            return "Leaving"
        }
        if time == "1" {
            return time + " Min"
        }
        return time + " Mins"
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfValidSections = 1
        // First check if able to pull station info
        guard let _ = stationInfo else {
            print("station info is invalid")
            return numOfValidSections
        }
        print("Station info pulled success")
        if successFullDataPull {
            print("sections should now be added")
            numOfValidSections = 1 + platformsAndTrains.count
        }
        
        return numOfValidSections
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let _ = stationInfo else {
            return 1
        }
        
        switch section {
            case 0:
                return 2
            case 1:
                print("Number of rows in 1: \(platformsAndTrains[1]!.count)")
                return platformsAndTrains[1]!.count
            case 2:
                print("Number of rows in 2: \(platformsAndTrains[2]!.count)")
                return platformsAndTrains[2]!.count
            case 3:
                print("Number of rows in 3: \(platformsAndTrains[3]!.count)")
                return platformsAndTrains[3]!.count
            default:
                return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
                case 0:
                    print("Setting up Station Map Cell...")
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationDetailMapCell.self), for: indexPath) as! StationDetailMapCell
                    if let station = stationInfo {
                        cell.locationToMap(location: station.location)
                    }
                    print("Completed Station Map Cell")
                    return cell
                case 1:
                    print("Setting up Station Detail Cell...")
                    let cell = tableView.dequeueReusableCell(withIdentifier: "StationDetailNameTableCell", for: indexPath) as! StationDetailNameTableCell
                    if let station = stationInfo {
                        cell.stationAddress.text = station.address
                        cell.stationCity.text = [station.city, station.zipcode].joined(separator: ", ")
                    }
                    print("Completed Station Detail Cell")
                    return cell
                default:
                    return UITableViewCell()
            }
        case 1:
            // PLATFORM 1
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationArrivalsCell.self), for: indexPath) as! StationArrivalsCell
            let cellTrain = platformsAndTrains[1]![indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            case 2:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = ""

            case 3:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = formatArrivalTime(cellTrain.nextEstimate[2].arrival)

            default:
                cell.firstTime.text = ""
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            }
            return cell
        case 2:
            // PLATFORM 2
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationArrivalsCell.self), for: indexPath) as! StationArrivalsCell
            let cellTrain = platformsAndTrains[2]![indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            case 2:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = ""

            case 3:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = formatArrivalTime(cellTrain.nextEstimate[2].arrival)

            default:
                cell.firstTime.text = ""
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            }
            return cell
        case 3:
            // PLATFORM 3
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationArrivalsCell.self), for: indexPath) as! StationArrivalsCell
            let cellTrain = platformsAndTrains[3]![indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            
            // find number of next estimaets
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            case 2:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = ""

            case 3:
                cell.firstTime.text = formatArrivalTime(cellTrain.nextEstimate[0].arrival)
                cell.secondTime.text = formatArrivalTime(cellTrain.nextEstimate[1].arrival)
                cell.thirdTime.text = formatArrivalTime(cellTrain.nextEstimate[2].arrival)

            default:
                cell.firstTime.text = ""
                cell.secondTime.text = ""
                cell.thirdTime.text = ""

            }
            
           return cell

        default:
            return UITableViewCell()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0,0] {
            return 215
        }
        return UITableView.automaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Platform 1"
        }
        if section == 2 {
            return "Platform 2"
        }
        if section == 3 {
            return "Platform 3"
        }
        return nil
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
