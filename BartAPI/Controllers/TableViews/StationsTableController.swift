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
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        
    }
    
    func filterContent(for searchText:String) {
        searchResults = stations.filter({ (station) -> Bool in
                let isMatch = station.name.localizedCaseInsensitiveContains(searchText)
                return isMatch
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "StationDetailSeque", sender: self )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    
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

extension StationsTableController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.changeNavBarColors_Ext()
        self.changeTabBarColors_Ext()
    }
}
