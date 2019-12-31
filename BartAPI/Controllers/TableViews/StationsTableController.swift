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

    override func viewDidLoad() {
        super.viewDidLoad()
    
        DispatchQueue.global(qos: .utility).async {
            self.getData()
        }
        tableView.tableFooterView = UIView()
        setUpSearchBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
//                    print(self.stations[0].name)
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
            print(error)
        }
        
        return stations
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationTableCell.self), for: indexPath) as! StationTableCell
        
        let station = (searchController.isActive) ? searchResults[indexPath.row] : stations[indexPath.row]
    

        // Configure the cell...

        cell.stationAbbr.text = station.abbreviation
        cell.stationAbbr.sizeToFit()
        cell.stationCity.text = station.city
        cell.stationName.text = station.name
        cell.stationAddress.text = station.address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected station: \(stations[indexPath.row].name)")
        performSegue(withIdentifier: "StationDetailSeque", sender: self)
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
                destinationController.stationAbbr = stations[indexPath.row].abbreviation
                destinationController.station = stations[indexPath.row]
                destinationController.navigationItem.title = stations[indexPath.row].abbreviation
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
