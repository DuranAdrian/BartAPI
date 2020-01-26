//
//  ModifiedHomeViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/25/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class ModifiedHomeViewController: UITableViewController {
    fileprivate let bartAPIKey = "MW9S-E7SL-26DU-VV8V"
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var activityMonitorView = UIActivityIndicatorView()
    
    var stations = [Station]()
    private var closestStation: Station?
    private var closestStationDistance: CLLocationDistance?
    var mapMode: MapMode = MapMode.blank
    
    var hasPulledData: Bool = false
    
    enum MapMode {
        case normal
        case restricted
        case blank
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setUpTableView()
        setUpNavView()
        
        // Get list of stations regardless of location enabled
        getStationList(completionHandler: { (value) in
            if value {
                print("Complete station list")
                DispatchQueue.main.async {
                    self.checkLocationPermissions()
                    self.activityMonitorView.stopAnimating()
                }

            } else {
                print("Error getting station list")
                // Default to show only user location if available and or bay area region
            }
            
        })

    }
    // GET LIST OF ALL STATIONS
    func getStationList(completionHandler: @escaping (Bool) -> Void) {
        let stationAPIUrl = "https://api.bart.gov/api/stn.aspx?cmd=stns&key=\(bartAPIKey)&json=y"
        guard let validStationURL = URL(string: stationAPIUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: validStationURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to stationList api: \(error)")
                completionHandler(false)
                return
            }
            
            if let data = data {
                // Connection successful
                self.stations = self.parseStationListData(data: data)
                completionHandler(true)
            }
        })
        task.resume()
        task.suspend()
        
    }
    
    func parseStationListData(data: Data) -> [Station] {
        let decoder = JSONDecoder()
        
        do {
            let stationDataStore = try decoder.decode(StationContainer.self, from: data)
            return stationDataStore.stations
        } catch {
            print("ERROR PARSING STATION LIST JSON DATA: \(error)")
        }
        
        return [Station]()
    }
    
    // GET NEAREST STATION
    func findClosetStation(completionHandler: @escaping (Bool) -> Void) {
        guard let userLocation = CLLocationManager().location else {
            print("Cannot find user location")
            return
        }
//        self.closestStation = stations[26]
//        self.closestStationDistance = userLocation.distance(from: stations[26].location)
//        completionHandler(true)
//        return
        self.activityMonitorView.startAnimating()
        var closestStation: Station?
        var smallestDistance: CLLocationDistance?
        for (index, station) in stations.enumerated() {
            let distance = userLocation.distance(from: station.location)
            if smallestDistance == nil || distance < smallestDistance! {
                closestStation = station
                smallestDistance = distance
            }
        }
        self.closestStation = closestStation
        self.closestStationDistance = smallestDistance
        completionHandler(true)
//        self.getTrainData("n")
//        self.getTrainData("s")
    
    }
    
    func setUpTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "HomeMapViewCell", bundle: nil), forCellReuseIdentifier: "HomeMapViewCell")
        self.tableView.register(UINib(nibName: "NearestStationTableCell", bundle: nil), forCellReuseIdentifier: "NearestStationTableCell")

    }
    
    func setUpNavView() {
        self.navigationItem.title = "Home"
        // MUST ADD BACKGROUND COLOR TO HIDE ADVISORY
        self.changeNavBarColors_Ext()
        let activityIcon = UIBarButtonItem(customView: activityMonitorView)
        self.navigationItem.setRightBarButton(activityIcon, animated: true)
        activityMonitorView.startAnimating()
    }
    
    func checkLocationPermissions(){
        // PERMISSION REQUEST WILL ONLY POP UP ONCE
        // CREATE CUSTOM ALERT TO TELL USERS TO GO TO SETTINGS TO ENABLE LOCATION
//        https://stackoverflow.com/questions/29980832/request-permissions-again-after-user-denies-location-services
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            print("Always Authorized")
            mapMode = .normal
            findClosetStation(completionHandler: { (value) in
                self.activityMonitorView.stopAnimating()
                self.hasPulledData = true
                self.tableView.reloadSections([0], with: .fade)
            })
            break
            
        case .authorizedWhenInUse:
            print("Authrized When In Use")
            mapMode = .normal
            findClosetStation(completionHandler: { (value) in
                self.activityMonitorView.stopAnimating()
                self.hasPulledData = true
                DispatchQueue.main.async {
                    self.tableView.reloadSections([0], with: .fade)
//                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                }
                
//                self.tableView.reloadData()
            })
            break
            
        case .denied:
            //Show alert with instructions to turn on
            print("Denied")
            mapMode = .restricted
            break
            
        case .notDetermined:
            print("Not Determined")
            locationManager.requestWhenInUseAuthorization()
            mapMode = .restricted
            tableView.reloadData()
            break
            
        case .restricted:
            print("Restricted")
            // User cannot change status
            mapMode = .restricted
            break
        
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            mapMode = .restricted
            break
        }
//        tableView.reloadData()
    }
    
    // FORMATTING FUNCTIONS
    
    func convertMetersToMiles(_ distance: Double) -> String {
        return String(format: "%.2f", ((distance / 1000.0 ) * 0.62137))
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        switch mapMode {
        case .blank:
            return 0
        case .restricted:
            print("RESTRICTED MODE IN NUMBER OF SECTIONS")
            return 1
        case .normal:
            return 1
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("INSIDE OF NUMBER OF ROWS IN.")
        switch mapMode {
        case .blank:
            return 0
            
        case .restricted:
            print("RESTRICTED MODE IN NUMBER OF ROWS IN SECTION")
            return 1
            
        case .normal:
            return 2
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mapMode {
        case .blank:
            return UITableViewCell()
            
        case .restricted:
            print("RESTRICTED MODE IN CELL FOR ROW AT")
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMapViewCell", for: indexPath) as! HomeMapViewCell
            
            cell.setUpRestricted(listOfStations: stations)
            
            return cell

        case .normal:
            print("NORMAL MODE IN CELL FOR ROW AT")
            
            switch indexPath.section {
            case 0:
                
                switch indexPath.row {
                case 0:
                    // MAP VIEW
                    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMapViewCell", for: indexPath) as! HomeMapViewCell
                    
                    cell.setUpNearest(nearestStation: closestStation!)
                    
                    return cell
                case 1:
                    // NEAREST STATION INFO
                    print("Inside of [0,1]")
                    if hasPulledData {
                        print("Has pulled data")
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationTableCell", for: indexPath) as! NearestStationTableCell
                        cell.stationDistance.text = String(describing: convertMetersToMiles(closestStationDistance!)) + " Miles"
                        cell.stationName.text = closestStation!.name
                        cell.isHidden = !hasPulledData
                        return cell

                    } else {
                        return UITableViewCell()
                    }
                    default:
                    return UITableViewCell()
                }
            case 1:
                switch indexPath.row {
                case 0:
                    // NEXT NORTH BOUND TRAIN
                    return UITableViewCell()
                case 1:
                    // NEXT SOUTH BOUND TRAIN
                    return UITableViewCell()
                default:
                    return UITableViewCell()
                }
                
            default:
                return UITableViewCell()
            }
            
//            switch indexPath.section {
//            case 0:
//                switch indexPath.row {
//                case 0:
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMapViewCell", for: indexPath) as! HomeMapViewCell
//
//                    cell.setUpNearest(nearestStation: closestStation!)
//                    return cell
//
//                default:
//                    return UITableViewCell()
//                }
//            default:
//                return UITableViewCell()
//            }
//
//            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Station Cell Map
         if indexPath.section == 0 {
            if indexPath.row == 0 {
                return self.view.getSafeAreaSize().height/2
            } else {
                return hasPulledData ? 68.0 : 0.0
//                return 68.0
            }
        } else {
            
            return hasPulledData ? 63.0 : 0.0
        }

    }
    

}

extension ModifiedHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermissions()
    }
}
