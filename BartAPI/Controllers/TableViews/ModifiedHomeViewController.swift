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
    
    // List of all stations
    var stations = [Station]()
    // Closest Station info
    private var closestStation: Station?
    private var closestStationDistance: CLLocationDistance?
    // Next directional trains for closest station
    private var nextNorthTrain: EstimateDeparture?
    private var nextSouthTrain: EstimateDeparture?
    // TIMER FOR PULLING NEXT TRAIN
    var timer: Timer?
    
    // Initial map mode
    var mapMode: MapMode = MapMode.blank
    
    // Check if closestStationData has been pulled successfully
    var hasPullClosestStation: Bool = false
    var hasPullNextNorthTrain: Bool = false
    var hasPullNextSouthTrain: Bool = false
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func setUpTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "HomeMapViewCell", bundle: nil), forCellReuseIdentifier: "HomeMapViewCell")
        tableView.register(UINib(nibName: "NearestStationTableCell", bundle: nil), forCellReuseIdentifier: "NearestStationTableCell")
        tableView.register(UINib(nibName: "NextTrainCell", bundle: nil), forCellReuseIdentifier: "NextTrainCell")
        tableView.register(UINib(nibName: "DelayedNextTrainCell", bundle: nil), forCellReuseIdentifier: "DelayedNextTrainCell")

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
                self.hasPullClosestStation = true
                self.tableView.reloadSections([0], with: .fade)
            })
            break
            
        case .authorizedWhenInUse:
            print("Authrized When In Use")
            mapMode = .normal
            findClosetStation(completionHandler: { (value) in
                self.activityMonitorView.stopAnimating()
                self.hasPullClosestStation = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if value {
                    self.getTrainData("n", completionHandler: { value in
                        if value {
                            self.hasPullNextNorthTrain = true
                            DispatchQueue.main.async {
                                print("Adding section...")
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
//                                self.tableView.reloadSections([1], with: .fade)
                            }
                        }
                    })
                    self.getTrainData("s", completionHandler: { value in
                        if value {
                            self.hasPullNextSouthTrain = true
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .fade)
                            }
                        }
                    })
                    self.createNextTrainsTimer()
//                    print(self.nextNorthTrain)
                }
                
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
    
    // CREATE TIMER TO ATTACH TO PULLING NEXT TRAIN EVERY 30 SECONDS
    func createNextTrainsTimer() {
        let initTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.nextTrainsTimerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(initTimer, forMode: .common)
        initTimer.tolerance = 0.5
        self.timer = initTimer
        
    }
    
    @objc func nextTrainsTimerFunction() {
        DispatchQueue.main.async {
            self.activityMonitorView.startAnimating()
        }
        DispatchQueue.backgroundThread(delay: 1.0, background: {
            self.getTrainData("n", completionHandler: { _ in })
            self.getTrainData("s", completionHandler: { _ in})
//            self.getAdvisoryData()
        }, completion: {
            if let _ = self.viewIfLoaded?.window {
                // View is active
                
                self.activityMonitorView.stopAnimating()
                self.tableView.reloadSections([1], with: .fade)
            } else {
                // View is not active
                
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
        for station in stations {
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
    
    // GET NEXT TRAIN DATA
    func getTrainData(_ direction: String, completionHandler: @escaping (Bool) -> Void) {
        let filteredTrainAPIUrl = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(String(describing: self.closestStation!.abbreviation.lowercased()))&dir=\(direction)&key=MW9S-E7SL-26DU-VV8V&json=y"

        guard let trainURL = URL(string: filteredTrainAPIUrl) else { print("HAD TO RETURN FROM TRAINURL"); return }
        DispatchQueue.main.async {
            self.activityMonitorView.startAnimating()
        }
        
        let task = URLSession.shared.dataTask(with: trainURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to filteredTrainAPIUrl: \(error)")
                return
            }
            
            ///connection succesfull
            if let data = data {
                if direction == "n" {
                    self.nextNorthTrain = self.findNextTrain(self.parseTrainJSONData(data: data), "North")
                } else {
                    self.nextSouthTrain = self.findNextTrain(self.parseTrainJSONData(data: data), "South")

                }
                DispatchQueue.main.async {
                    self.activityMonitorView.stopAnimating()
                    completionHandler(true)
                }
                
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
//            print("FOUND TRAINS: \(parsedTrains)")
        } catch {
            print("Error parsing Train JSON Data: \(error)")
        }
        
        return parsedTrains
    }
        
    // Find next train
    /// ACCORDING TO THE BART API. THE NEXT ARRIVAL WILL ALWAYS BE AT INDEX [0], THUS NO NEED TO ITERATE THROUGH ALL ESTIMATES
    // CAN PROBABLY BE OPTIMIZED A BIT BUT FOR NOW IT WILL DO.
    func findNextTrain(_ trains: [Train], _ direction: String) -> EstimateDeparture {
        var nextTrainAtTime: Int32 = UINT8_MAX
        var position = 0
        for (index, destination) in trains[0].estimate.enumerated() {
            var checkingNexttime: Int32
            if destination.nextEstimate[0].arrival == "Leaving" {
                checkingNexttime = 0
            } else {
                checkingNexttime = Int32(destination.nextEstimate[0].arrival)!
            }
            if checkingNexttime < nextTrainAtTime {
                nextTrainAtTime = checkingNexttime
                position = index
            }
        }
        return trains[0].estimate[position]
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
            return 1
            
        case .normal:
            print("NUMBER OF SECTIONS == 2")
            return 2
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
            print("NUMBER OF ROWS IN EACH SECTION == 2")
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
                    if hasPullClosestStation {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationTableCell", for: indexPath) as! NearestStationTableCell
                        cell.stationDistance.text = String(describing: convertMetersToMiles(closestStationDistance!)) + " Miles"
                        cell.stationName.text = closestStation!.name
                        cell.isHidden = !hasPullClosestStation
                        return cell

                    } else {
                        return UITableViewCell()
                    }
                    default:
                    return UITableViewCell()
                }
            case 1:
                print("Inside section 2")
                switch indexPath.row {
                case 0:
                    // NEXT NORTH BOUND TRAIN
                    if hasPullNextNorthTrain {
                        // ENSURE NEXTNORTHTRAIN IS NOT NIL
                        guard let train = nextNorthTrain else {
                            return UITableViewCell()
                        }
                        // NEXT NORTH TRAIN IS NOW VALID
                        if train.nextEstimate[0].isDelayed() {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "DelayedNextTrainCell", for: indexPath) as! DelayedNextTrainCell
                            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
                            cell.routeColorView.backgroundColor = color?.colors
                            cell.routeDirection.text = train.nextEstimate[0].direction
                            cell.destination.text = train.destination
                            if train.nextEstimate[0].arrival == "Leaving" {
                                cell.timeUntilArrival.text = "Leaving Now"
                            } else {
                                cell.timeUntilArrival.text = "\(Int(train.nextEstimate[0].arrival)! + train.nextEstimate[0].computeDelayTime()) Mins"
                            }
                            
                            return cell
                        } else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
                            print(train.nextEstimate[0].color)
                            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
                            cell.routeColorView.backgroundColor = color?.colors
                            cell.routeDirection.text = train.nextEstimate[0].direction
                            cell.destination.text = train.destination
                            if train.nextEstimate[0].arrival == "Leaving" {
                                cell.timeUntilArrival.text = "Leaving Now"
                            } else {
                                cell.timeUntilArrival.text = "\(Int(train.nextEstimate[0].arrival)! + train.nextEstimate[0].computeDelayTime()) Mins"
                            }
                            
                            return cell

                        }
                        
                    }
                    let cell = UITableViewCell()
                    cell.isHidden = true
                    return cell
                case 1:
                    // NEXT SOUTH BOUND TRAIN
                    if hasPullNextSouthTrain {
                        // ENSURE NEXTNORTHTRAIN IS NOT NIL
                        guard let train = nextSouthTrain else {
                            return UITableViewCell()
                        }
                        // NEXT NORTH TRAIN IS NOW VALID
                        if train.nextEstimate[0].isDelayed() {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "DelayedNextTrainCell", for: indexPath) as! DelayedNextTrainCell
                            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
                            cell.routeColorView.backgroundColor = color?.colors
                            cell.routeDirection.text = train.nextEstimate[0].direction
                            cell.destination.text = train.destination
                            if train.nextEstimate[0].arrival == "Leaving" {
                                cell.timeUntilArrival.text = "Leaving Now"
                            } else {
                                cell.timeUntilArrival.text = "\(Int(train.nextEstimate[0].arrival)! + train.nextEstimate[0].computeDelayTime()) Mins"
                            }
                            
                            return cell
                        } else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
                            print(train.nextEstimate[0].color)
                            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
                            cell.routeColorView.backgroundColor = color?.colors
                            cell.routeDirection.text = train.nextEstimate[0].direction
                            cell.destination.text = train.destination
                            if train.nextEstimate[0].arrival == "Leaving" {
                                cell.timeUntilArrival.text = "Leaving Now"
                            } else {
                                cell.timeUntilArrival.text = "\(Int(train.nextEstimate[0].arrival)! + train.nextEstimate[0].computeDelayTime()) Mins"
                            }
                            
                            return cell

                        }
                        
                    }
                    let cell = UITableViewCell()
                    cell.isHidden = true
                    return cell

                default:
                    let cell = UITableViewCell()
                    cell.isHidden = true
                    return cell

                }
                
            default:
                let cell = UITableViewCell()
                cell.isHidden = true
                return cell

            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Station Cell Map
         if indexPath.section == 0 {
            if indexPath.row == 0 {
                return self.view.getSafeAreaSize().height/2
            } else {
                return hasPullClosestStation ? 68.0 : 0.0
            }
         } else {
            // IN CASE THERES IS ONLY ONE DIRECTION
            if indexPath.row == 0 {
                return hasPullNextNorthTrain ? 63.0 : 0.0
            } else {
                return hasPullNextSouthTrain ? 63.0 : 0.0
            }
        }

    }
    

}

extension ModifiedHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermissions()
    }
}
