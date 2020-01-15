//
//  StationsTableController.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit

class StationsTableController: UITableViewController {
    
    
    let bartAPIKey = "MW9S-E7SL-26DU-VV8V"
    let stationAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V&json=y"

    var searchController = UISearchController()
    
    var stations = [Station]()
    var searchResults = [Station]()
    var stationSelected = StationInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        DispatchQueue.global(qos: .utility).async {
            self.getData()
        }
        setUpTableView()
        setUpSearchBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setUpTableView() {
        tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "StationTableCell_2", bundle: nil), forCellReuseIdentifier: "StationTableCell_2")

    }
    
    func setUpNavBar() {
        self.navigationItem.title = "All Stations"
    }

    func setUpSearchBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        
    }
    
    func filterContent(for searchText:String) {
        searchResults = stations.filter({ (station) -> Bool in
//            if let name = station.name {
//            let begins = station.name.starts(with: searchText)
                let isMatch = station.name.localizedCaseInsensitiveContains(searchText)
                return isMatch
//            }
//            return false
        })
    }

    func getData() {
        guard let stationURL = URL(string: stationAPIURL) else { return }
        
        let task = URLSession.shared.dataTask(with: stationURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to stationAPI: \(error)")
                return
            }
            
            ///connection succesfull
            if let data = data {
                self.stations = self.parseJSONData(data: data)
                
                OperationQueue.main.addOperation {
                    print("Stations Data has been parsed, reloading View.")
                    self.tableView.reloadData()
                }
            }
            
        })
        task.resume()
    }
    
    func parseJSONData(data: Data) -> [Station] {
        var stations = [Station]()
        let decoder = JSONDecoder()
        
        do {
            let stationDataStore = try decoder.decode(StationContainer.self, from: data)
            stations = stationDataStore.stations
        } catch {
            print("ERROR PARSING STATIONLIST JSON DATA:  \(error)")
        }
        
        return stations
    }
    
    
    func getStationInfoData(_ station: Station) -> StationInfo {
        var stationToReturn: StationInfo = StationInfo()
        let stationInfoAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=\(String(describing: station.abbreviation.lowercased()))&key=\(bartAPIKey)&json=y"
            guard let stationURL = URL(string: stationInfoAPIURL) else { return stationToReturn }
            
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
                    stationToReturn = self.parseStationInfoJSONData(data: data)
                }
                
            })
            task.resume()
            print("Found Station Info: \(stationToReturn)")
            return stationToReturn
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
        
        return stationInfoItem[0]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        } else {
            return stations.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationTableCell_2.self), for: indexPath) as! StationTableCell_2
        
        let station = (searchController.isActive) ? searchResults[indexPath.row] : stations[indexPath.row]
    

        // Configure the cell...

        cell.stationAbbr.text = station.abbreviation
        cell.stationAbbr.sizeToFit()
        cell.stationCity.text = station.city
        cell.stationName.text = station.name
//        cell.stationAddress.text = station.address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = (searchController.isActive) ? searchResults[indexPath.row] : stations[indexPath.row]
        print("Selected station: \(station.name)")
        print("Performing segue with sender: \(self)")
//        DispatchQueue.backgroundThread(delay: 0.0, background: {self.stationSelected = self.getStationInfoData(station)}, completion: {self.performSegue(withIdentifier: "StationDetailSeque", sender: self )})
        self.performSegue(withIdentifier: "StationDetailSeque", sender: self )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "StationDetailSeque" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! StationDetailViewController
                let selectedStation = (searchController.isActive) ? searchResults[indexPath.row] : stations[indexPath.row]
                destinationController.stationAbbr = selectedStation.abbreviation
                destinationController.station = selectedStation
//                destinationController.navigationItem.title = selectedStation.name
                
                // create UILabel

                
                
                
            }
            
        }
    }
    

}

extension StationsTableController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}
