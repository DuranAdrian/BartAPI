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
    var mapView: MKMapView!
    fileprivate let locationManager: CLLocationManager! = CLLocationManager()

    var stations = [Station]()
    var northTrains = [Train]()
    var nextNorthTrain = EstimateDeparture()
    var southTrains = [Train]()
    var nextSouthTrain = EstimateDeparture()
    var closestStation: Station?
    var closestDistance: CLLocationDistance?
    
    let activityView: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer: Timer?
    var popUp: AdvisoryPopUp!
    var hidePopUpContraint: NSLayoutConstraint!
    var showPopUpContraint: NSLayoutConstraint!
    
    var hasPulledData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpTableView()

        // load nearest station using .userInteractive
        DispatchQueue.userInteractiveThread(delay: 5.0, background: { self.getData() }, completion: {
            print("Has pulled data complete")
            self.hasPulledData = true
            self.getAdvisoryData()
            self.activityView.stopAnimating()
            self.tableView.reloadSections([0,1], with: .fade)
            print("Starting background thread timer...")
            self.createtimer()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Timer should be invalidated..")
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = timer else {
            return
        }
        createtimer()
    }
    
    func createAdvisory(_ adv: Advisory) {
        
        popUp = AdvisoryPopUp()
        popUp.layer.borderColor = UIColor.Custom.annotationBlue.cgColor
        popUp.layer.backgroundColor = UIColor.Custom.errorRed.cgColor
        popUp.layer.borderWidth = 1.0
        popUp.layer.cornerRadius = 15.0
        popUp.layer.masksToBounds = true
        popUp.tag = 100
        popUp.setMessage(message: adv.bsa[0].description)
        let tapToRemoveGesture = UITapGestureRecognizer(target: self, action: #selector(hidePopUp(_:)))
        tapToRemoveGesture.numberOfTouchesRequired = 1
        tapToRemoveGesture.numberOfTapsRequired = 1
        popUp.addGestureRecognizer(tapToRemoveGesture)
        
        self.tableView.addSubview(popUp)
        
        // Hide above screen
        popUp.translatesAutoresizingMaskIntoConstraints = false
        popUp.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5).isActive = true
        popUp.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
        hidePopUpContraint = popUp.bottomAnchor.constraint(equalTo: self.tableView.topAnchor)
        showPopUpContraint = popUp.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 10)
        
        hidePopUpContraint.isActive = true
        showPopUpContraint.isActive = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.hidePopUpContraint.isActive = false
            self.showPopUpContraint.isActive = true
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
                self.tableView.layoutIfNeeded()
            }, completion: nil)
            
        })
        
    }
    
    func getAdvisoryData() {
//        let urlString = "https://api.bart.gov/api/bsa.aspx?cmd=bsa&key=MW9S-E7SL-26DU-VV8V&json=y"
        let urlString = "https://api.bart.gov/api/bsa.aspx?cmd=bsa&key=MW9S-E7SL-26DU-VV8V&json=y"
        guard let advisoryURL = URL(string: urlString) else { print("adv failed"); return }
        let task = URLSession.shared.dataTask(with: advisoryURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to ADVISORYAPI: \(error)")
                return
            }
            
            if let data = data {
                let test = self.parseAdvisoryData(data: data)
                print("displaying advisory....")
                
                DispatchQueue.main.async {
                    self.createAdvisory(test)
                }
            }
            
        })
        task.resume()
    }
    
    func parseAdvisoryData(data: Data) -> Advisory {
        let decoder = JSONDecoder()
        do {
            let dataStore = try decoder.decode(Advisory.self, from: data)
            return dataStore
        } catch {
            print("Error parsing JSON")
        }
        return Advisory()
    }
    
    @objc func hidePopUp(_ sender: UITapGestureRecognizer) {
        self.showPopUpContraint.isActive = false
        self.hidePopUpContraint.isActive = true
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.tableView.layoutIfNeeded()
        }, completion: { _ in
            self.tableView.viewWithTag(100)?.removeFromSuperview()
        })
    }
    
    func createtimer() {
        let initTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.timerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(initTimer, forMode: .common)
        initTimer.tolerance = 0.5
        self.timer = initTimer
        
//        DispatchQueue.backgroundThread(delay: 5.0, background: {
//            print("INSIDE BACKGROUND THREAD")
//            let initTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timerFunction), userInfo: nil, repeats: true)
//            RunLoop.current.add(initTimer, forMode: .common)
//            initTimer.tolerance = 0.1
//            self.timer = initTimer
//            print("Timer complete") }, completion: {
//
//            print("Backgroundthread should be complete")
//            self.tableView.reloadSections([1], with: .fade)
//        })
        
    }
    @objc func timerFunction() {
        print("PULLING NEW DATA! \(Date())")
        self.activityView.startAnimating()
        DispatchQueue.backgroundThread(delay: 1.0, background: {
            self.getTrainData("n")
            self.getTrainData("s")
        }, completion: {
            self.activityView.stopAnimating()
            self.tableView.reloadSections([1], with: .fade)
        })
        
    }
    
            
    func setUpTableView() {
        self.tableView.tableFooterView = UIView()
//        self.tableView.separatorInset = UIEdgeInsets.zero
//        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.register(UINib(nibName: "StationMapTableCell", bundle: nil), forCellReuseIdentifier: "StationMapTableCell")
        self.tableView.register(UINib(nibName: "NearestStationTableCell", bundle: nil), forCellReuseIdentifier: "NearestStationTableCell")
        self.tableView.register(UINib(nibName: "NextTrainCell", bundle: nil), forCellReuseIdentifier: "NextTrainCell")
        self.tableView.register(UINib(nibName: "DelayedNextTrainCell", bundle: nil), forCellReuseIdentifier: "DelayedNextTrainCell")
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = UITableView.automaticDimension
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
    }
    
    func setUpNavBar() {
        self.navigationItem.title = "Home"
        // MUST ADD BACKGROUND COLOR TO HIDE ADVISORY
        changeNavBarColor()
        if !hasPulledData {
            let activityIcon = UIBarButtonItem(customView: activityView)
            self.navigationItem.setRightBarButton(activityIcon, animated: true)
            activityView.startAnimating()
            
        }
    }
    
    func changeNavBarColor() {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            if self.traitCollection.userInterfaceStyle == .dark {
                appearance.backgroundColor = .black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                self.navigationController?.navigationBar.tintColor = .black

            } else {
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

                self.navigationController?.navigationBar.tintColor = .white

            }
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.layoutSubviews()
            self.navigationController?.navigationBar.layoutIfNeeded()
        } else {

            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
        
    /// Get nearest station
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
                
                ///Stations exist, can now find closest station
                self.findClosetStation()
                OperationQueue.main.addOperation {
                    print("Stations Data has been successfully parsed, reloading View.")
//                    self.tableView.reloadData()
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
            print("ERROR PARSING STATION LIST JSON DATA: \(error)")
        }
        
        return stations
    }
    
    /// Get Next Train at nearest station
    func getTrainData(_ direction: String) {
        let filteredTrainAPIUrl = "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(String(describing: self.closestStation!.abbreviation.lowercased()))&dir=\(direction)&key=MW9S-E7SL-26DU-VV8V&json=y"

        guard let trainURL = URL(string: filteredTrainAPIUrl) else { print("HAD TO RETURN FROM TRAINURL"); return }
            
        let task = URLSession.shared.dataTask(with: trainURL, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Could not connect to filteredTrainAPIUrl: \(error)")
                return
            }
            
            ///connection succesfull
            if let data = data {
                if direction == "n" {
                    self.northTrains = self.parseTrainJSONData(data: data)
//
                    self.nextNorthTrain = self.findNextTrain(self.northTrains, "North")
                    
                } else {
                    self.southTrains = self.parseTrainJSONData(data: data)
                    self.nextSouthTrain = self.findNextTrain(self.southTrains, "South")

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
        print("Next train heading to \(trains[0].estimate[position].destination) in about \(nextTrainAtTime) minutes")
        return trains[0].estimate[position]
    }
    
    func findClosetStation() {
        guard let userLocation = CLLocationManager().location else {
            print("Cannot find user location")
            return
        }

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
        self.getTrainData("n")
        self.getTrainData("s")
    }
    
    func convertMetersToMiles(_ distance: Double) -> String {
        return String(format: "%.2f", ((distance / 1000.0 ) * 0.62137))
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // Each section has 2 rows
        return 2

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Section one contains mapview and nearest Station
        // Section 2 contains next trains arriving at platforms
        if (hasPulledData && section == 1) {
            return "Next Arriving Train"
        }
        return nil
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MAP View and closest station
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StationMapTableCell", for: indexPath) as! StationDetailMapCell
                
                // Configure the cell...
                cell.initialZoom()
                cell.setUpLocationManager(closestStation)

                return cell
            case 1:
                if stations.count == 0 {
                    print("Data has not been collected, Cannot create cell. return empty tablecell")
                    
                    let cell = UITableViewCell()
                    cell.isHidden = hasPulledData ? false : true
                    return cell
                    
                } else {
                    print("Data has been succesfully collected, can now create cell")
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationTableCell", for: indexPath) as! NearestStationTableCell

                    cell.stationName.text = closestStation!.name
                    cell.stationDistance.text = String(describing: convertMetersToMiles(closestDistance!)) + " Miles"
                    cell.isHidden = hasPulledData ? false : true
                    
                    return cell
                }
                
            default:
                print("Error creating cell at indexpath: row \(indexPath.row), section \(indexPath.section)")
                let cell = UITableViewCell()
                cell.isHidden = true
                return cell
            }
        }
        else {
            switch indexPath.row {
            case 0:
                // NORTH TRAIN
                if hasPulledData {
                    /// Find if Delays
//                    print(nextNorthTrain.nextEstimate[0])
                    if (nextNorthTrain.nextEstimate[0].isDelayed()) {

                        let cell = tableView.dequeueReusableCell(withIdentifier: "DelayedNextTrainCell", for: indexPath) as! DelayedNextTrainCell
                        cell.isHidden = !hasPulledData
                        let color = UIColor.BARTCOLORS(rawValue: nextNorthTrain.nextEstimate[0].color)
                        cell.routeColorView.backgroundColor = color?.colors
                        cell.routeDirection.text = nextNorthTrain.nextEstimate[0].direction
                        cell.destination.text = nextNorthTrain.destination
                        if nextNorthTrain.nextEstimate[0].arrival == "Leaving" {
                            cell.timeUntilArrival.text = "Leaving Now"
                        } else {
                            cell.timeUntilArrival.text = "\(Int(nextNorthTrain.nextEstimate[0].arrival)! + nextNorthTrain.nextEstimate[0].computeDelayTime()) Mins"
                        }
                        
                        return cell

                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
                    
                        cell.isHidden = !hasPulledData
                        let color = UIColor.BARTCOLORS(rawValue: nextNorthTrain.nextEstimate[0].color)
                        cell.routeColorView.backgroundColor = color?.colors
                        cell.routeDirection.text = nextNorthTrain.nextEstimate[0].direction
                        cell.destination.text = nextNorthTrain.destination
                        if nextNorthTrain.nextEstimate[0].arrival == "Leaving" {
                            cell.timeUntilArrival.text = "Leaving Now"
                        } else {
                            cell.timeUntilArrival.text = "\(nextNorthTrain.nextEstimate[0].arrival) Mins"
                        }
                        
                        return cell
                    }
                    
                } else {
                let cell = UITableViewCell()
        
                cell.isHidden = !hasPulledData
                
                return cell
            }
                
            case 1:
                // SOUTH TRAIN
                
                if hasPulledData {
                    /// Find if Delays
                    // FIXME :-  INDEX OUT OF RANGE
                    print(nextSouthTrain.nextEstimate[0])
                    if (nextSouthTrain.nextEstimate[0].isDelayed()) {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "DelayedNextTrainCell", for: indexPath) as! DelayedNextTrainCell
                        cell.isHidden = !hasPulledData
                        let color = UIColor.BARTCOLORS(rawValue: nextSouthTrain.nextEstimate[0].color)
                        cell.routeColorView.backgroundColor = color?.colors
                        cell.routeDirection.text = nextSouthTrain.nextEstimate[0].direction
                        cell.destination.text = nextSouthTrain.destination
                        if nextSouthTrain.nextEstimate[0].arrival == "Leaving" {
                            cell.timeUntilArrival.text = "Leaving Now"
                        } else {
                            cell.timeUntilArrival.text = "\(Int(nextSouthTrain.nextEstimate[0].arrival)! + nextSouthTrain.nextEstimate[0].computeDelayTime()) Mins"
                        }
                        
                        return cell

                    } else {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
                        cell.isHidden = !hasPulledData
                        let color = UIColor.BARTCOLORS(rawValue: nextSouthTrain.nextEstimate[0].color)
                        cell.routeColorView.backgroundColor = color?.colors
                        cell.routeDirection.text = nextSouthTrain.nextEstimate[0].direction
                        cell.destination.text = nextSouthTrain.destination
                        if nextSouthTrain.nextEstimate[0].arrival == "Leaving" {
                            cell.timeUntilArrival.text = "Leaving Now"
                        } else {
                            cell.timeUntilArrival.text = "\(nextSouthTrain.nextEstimate[0].arrival) Mins"
                        }
                        
                        return cell
                    }
                    
                } else {
                    
                    let cell = UITableViewCell()
                    cell.isHidden = !hasPulledData
                    
                    return cell
                }
            default:
                print("Error creating cell at indexpath: row \(indexPath.row), section \(indexPath.section)")
                
                let cell = UITableViewCell()
                cell.isHidden = true
                return cell
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return self.view.getSafeAreaSize().height/2
            } else {
                return hasPulledData ? 68.0 : 0.0
            }
        } else {
            
            return hasPulledData ? 63.0 : 0.0
        }

    }

}

extension HomeScreenTableViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        changeNavBarColor()
    }
}
