//
//  HomeScreenTableViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/20/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class HomeScreenTableViewController: UITableViewController {
    let stationAPIURL = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V&json=y"


    var stations = [Station]()
    var closestStation: Station?
    var closestDistance: CLLocationDistance?
    
    var testFlag: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpNavBar()

        // load nearest station using .userInteractive
        print("ViewDidLoad thread: \(Thread.current)")
        DispatchQueue.userInteractiveThread(delay: 5.0, background: { self.getData() }, completion: {
            print("UIThread thread: \(Thread.current)")
            self.testFlag = false
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)], with: .fade)
//            print("Coming back from thread: ",self.stations)
        })
        
        //        self.tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
        
    func setUpTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "StationMapTableCell", bundle: nil), forCellReuseIdentifier: "StationMapTableCell")
        self.tableView.register(UINib(nibName: "NearestStationTableCell", bundle: nil), forCellReuseIdentifier: "NearestStationTableCell")
    }
    
    func setUpNavBar() {
        self.navigationItem.title = "Home"
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
                print("Current thread: \(Thread.current)")
                self.stations = self.parseJSONData(data: data)
                print("")
                ///Stations exist, can now find closest station
                self.findClosetStation()
                OperationQueue.main.addOperation {
                    print("Stations Data has been successfully parsed, reloading View.")
//                    print(self.stations[0].name)
//                        self.tableView.reloadData()
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
//            print(stations)
        } catch {
            print(error)
        }
        
        return stations
    }
    
    func findClosetStation() {
        print("Stations exist, can now attempt to look for closest station")
        guard let userLocation = CLLocationManager().location else {
            print("Cannot find user location")
            return
        }

        print("Successfully found user location")
        var closestStation: Station?
        var smallestDistance: CLLocationDistance?
        for station in stations {
            let distance = userLocation.distance(from: station.location)
            if smallestDistance == nil || distance < smallestDistance! {
                closestStation = station
                smallestDistance = distance
            }
        }
        self.closestStation = closestStation
        self.closestDistance = smallestDistance
    }
    
    func convertMetersToMiles(_ distance: Double) -> String {
        return String(format: "%.2f", ((distance / 1000.0 ) * 0.62137))
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if CLLocationManager.locationServicesEnabled() {
//            print("LocationTRUE")
            return 3
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StationMapTableCell", for: indexPath) as! StationDetailMapCell
            
            // Configure the cell...
            cell.setUpLocationManager(closestStation)

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationTableCell", for: indexPath) as! NearestStationTableCell
            // Get current user location
            // get list of station coordinates
//            print(stations)
//            guard let confirmedStations = stations.count else { print("Stations has not been initialized"); return cell }
//            print(confirmedStations)
            if stations.count == 0 {
                print("Data has not been colllected, Cannot create cell")
                cell.isHidden = testFlag ? true : false
                return cell
            } else {
                print("Data has been succesfully collected, can now create cell")
                cell.stationName.text = closestStation!.name
                cell.stationDistance.text = String(describing: convertMetersToMiles(closestDistance!)) + " Miles"
                cell.isHidden = testFlag ? true : false
                return cell
            }
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationTableCell", for: indexPath) as! NearestStationTableCell
            // Get current user location
            // get list of station coordinates
//            print(stations)
            cell.stationName.text = "Row should be pushed down soon"
            cell.stationDistance.text = "0.0 Miles"
            return cell
              
        default:
            fatalError("Error intializing home screen")
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return self.view.getSafeAreaSize().height/2
        case 1:
            return testFlag ? 0 : 100.0
//            return 100.0
        case 2:
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
    
    // MARK: - MapView
    

}
