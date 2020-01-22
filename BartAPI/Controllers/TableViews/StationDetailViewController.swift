//
//  StationDetailViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

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
    var platformSections: [Int] = []
    var routes: [Route]!
    var successFullDataPull: Bool = false
    let activityView: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer: Timer?
    
    // MapView for table cell
    var customMapView: MKMapView = MKMapView()
    var willShowRoute: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpNavBar()
        DispatchQueue.userInitiatedThread(delay: 1.0, background: {
            self.getStationInfoData()
        }, completion: {
            DispatchQueue.userInitiatedThread(delay: 1.0, background: {
                self.getRouteData()
                self.getTrainData()
            }, completion: {
                self.successFullDataPull = true
                self.activityView.stopAnimating()
                print("COUNT: \(self.platformSections.count)")
                if self.platformSections.count > 0 {
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(IndexSet(integersIn: 1...self.platformSections.count), with: .fade)
                    self.tableView.reloadData()
                    self.tableView.endUpdates()
                    self.createtimer()
                }
            })
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.activityView.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func setUpTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 215.0
        tableView.register(UINib(nibName: "StationDetailNameTableCell", bundle: nil), forCellReuseIdentifier: "StationDetailNameTableCell")
        tableView.register(UINib(nibName: "StationArrivalsCell", bundle: nil), forCellReuseIdentifier: "StationArrivalsCell")
        tableView.register(UINib(nibName: "ModifiedStationDetailMapCell", bundle: nil), forCellReuseIdentifier: "ModifiedStationDetailMapCell")
        tableView.register(UINib(nibName: "StationDelayedArrivalsCell", bundle: nil), forCellReuseIdentifier: "StationDelayedArrivalsCell")
        
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
        
        if !successFullDataPull {
            let activityIcon = UIBarButtonItem(customView: activityView)
            self.navigationItem.setRightBarButton(activityIcon, animated: true)
            self.activityView.startAnimating()
        }

    }
    
    // Timer for pulling data on background
    func createtimer() {
        let trainTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.timerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(trainTimer, forMode: .common)
        trainTimer.tolerance = 0.5
        self.timer = trainTimer
    }
    
    @objc func timerFunction() {
        self.activityView.startAnimating()
        DispatchQueue.backgroundThread(delay: 1.0, background: {
            self.getTrainData()
        }, completion: {
            self.activityView.stopAnimating()
            if self.platformSections.count > 0 {
                self.tableView.reloadSections(IndexSet(integersIn: 1...self.platformSections.count), with: .fade)

            }
        })
        
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
                let _ = self.parseTrainJSONData(data: data)
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
            return parsedTrains
            
        }
        
        return parsedTrains
    }
    
    func setUpTrains(_ trainList: [Train]) {
        var listOfTrains: [Int: [EstimateDeparture]]! = [:]
        for train in trainList[0].estimate {
            if let _ = listOfTrains[Int(train.nextEstimate[0].platform)!] {
                // key exist, only append to array
                listOfTrains[Int(train.nextEstimate[0].platform)!]?.append(train)
            } else {
                // key does not exist, add key, start new array
                listOfTrains[Int(train.nextEstimate[0].platform)!] = [train]
            }
        }
        
        var platformNum: Int = 1
        var numSections: [Int] = []
        for (index, value) in listOfTrains.enumerated() {
            numSections.append(platformNum)
            platformNum += 1
        }
        platformSections = numSections
        platformsAndTrains = listOfTrains
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
        switch time {
        case "leaving":
            return "Leaving"
        case "Leaving":
            return "Leaving"
        case "1":
            return time + " Min"
        default:
            return time + " Mins"
        }
        
    }
    
    func formatDelayArrival(_ estimate: Estimate) -> NSAttributedString {
        var normalArrival: String
        var normalAttributes: [NSAttributedString.Key: NSObject]
        switch estimate.arrival {
            case "leaving":
                normalArrival = "Leaving"
            case "Leaving":
                normalArrival = "Leaving"
            case "1":
                normalArrival = "1 Min"
            default:
                normalArrival = estimate.arrival + " Mins"
        }
        if #available(iOS 13, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                normalAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.white]
            } else {
                normalAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.black]

            }
        } else {
            normalAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        
        if estimate.isDelayed() {
            // Change color to red
            let delayedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.Custom.errorRed, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]
            // Add delayed time to actual time
            var delayedArrival: String
            var arrivalPlaceHolder: Int
            switch estimate.arrival {
                case "leaving":
                    arrivalPlaceHolder = 0
                    break
                case "Leaving":
                    arrivalPlaceHolder = 0
                    break
                default:
                    arrivalPlaceHolder = Int(estimate.arrival)!
            }
            arrivalPlaceHolder = arrivalPlaceHolder + estimate.computeDelayTime()
            switch arrivalPlaceHolder {
            case 0:
                delayedArrival = "Leaving"
                break
            case 1:
                delayedArrival = "1 Min"
                break
            default:
                delayedArrival = "\(arrivalPlaceHolder) Mins"
            }
            
            return NSAttributedString(string: delayedArrival, attributes: delayedAttributes)
        }
        
        return NSAttributedString(string: normalArrival, attributes: normalAttributes)

    }
    
    // Map Manipulation
    
    @objc func findRoute(_ sender: UIButton) {
        print("Attemping to find route...")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfValidSections = 1
        // First check if able to pull station info
        guard let _ = stationInfo else {
            return numOfValidSections
        }
        if successFullDataPull {
            numOfValidSections = 1 + platformSections.count
        }
        
        return numOfValidSections
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let _ = stationInfo else {
            return 1
        }
//        print(platformsAndTrains)
        let keys = Array(platformsAndTrains.keys).sorted()
        switch section {
            case 0:
                return 2
            case 1:
//                print("Number of rows in 1: \(platformsAndTrains[keys[0]]!.count)")
                return platformsAndTrains[keys[0]]!.count
            case 2:
//                print("Number of rows in 2: \(platformsAndTrains[keys[1]]!.count)")
                return platformsAndTrains[keys[1]]!.count
            case 3:
//                print("Number of rows in 3: \(platformsAndTrains[keys[2]]!.count)")
                return platformsAndTrains[keys[2]]!.count
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ModifiedStationDetailMapCell.self), for: indexPath) as! ModifiedStationDetailMapCell
                    cell.mapView.delegate = self
                    if willShowRoute {
                        cell.mapView.routeToDestination(stationInfo.location)
                    } else {
                        cell.mapView.removeRoute()
                        cell.mapView.addLocation(station.location)
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
                    cell.routeDelegate = self
//                    cell.findRouteButton.target(forAction: #selector(findRoute(_:)), withSender: self)
                    print("Completed Station Detail Cell")
                    return cell
                default:
                    return UITableViewCell()
            }
        case 1:
            // PLATFORM 1
            print("1: Setting up StationDelayedArrivalsCell Cell...")
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationDelayedArrivalsCell.self), for: indexPath) as! StationDelayedArrivalsCell
            let key = Array(platformsAndTrains.keys).sorted()
            let cellTrain = platformsAndTrains[key[0]]![indexPath.row]
            
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            var foundDelay: Bool = false
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in cellTrain.nextEstimate {
                if train.isDelayed() {
                    foundDelay = true
                    break findDelay
                }
            }
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.text = " "

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[2])
//                cell.thirdTime.text = " "

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            }
            return cell
        case 2:
            // PLATFORM 2
            print("2: Setting up StationDelayedArrivalsCell Cell...")
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationDelayedArrivalsCell.self), for: indexPath) as! StationDelayedArrivalsCell
            
            let key = Array(platformsAndTrains.keys).sorted()
            let cellTrain = platformsAndTrains[key[1]]![indexPath.row]
            
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            var foundDelay = false
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in cellTrain.nextEstimate {
                if train.isDelayed() {
                    foundDelay = true
                    break findDelay
                }
            }
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.text = " "

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[2])

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            }
            return cell
        case 3:
            // PLATFORM 3
            print("3: Setting up StationDelayedArrivalsCell Cell...")
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StationDelayedArrivalsCell.self), for: indexPath) as! StationDelayedArrivalsCell
            
            let key = Array(platformsAndTrains.keys).sorted()
            let cellTrain = platformsAndTrains[key[2]]![indexPath.row]
            
            let color = UIColor.BARTCOLORS(rawValue: cellTrain.nextEstimate[0].color)
            var foundDelay: Bool = false
            cell.routeColorView.backgroundColor = color?.colors
            cell.destinationName.text = cellTrain.destination
            cell.directionLabel.text = cellTrain.nextEstimate[0].direction
            
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in cellTrain.nextEstimate {
                if train.isDelayed() {
                    foundDelay = true
                    break findDelay
                }
            }
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            // find number of next estimaets
            switch cellTrain.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.text = " "

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(cellTrain.nextEstimate[2])

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

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
        let keys = Array(platformsAndTrains.keys).sorted()
        if section == 1 {
            return "Platform \(platformsAndTrains[keys[0]]![0].nextEstimate[0].platform)"
//            print("Keys at index 0: \(keys[0])")
//            return ""
//            return "Platform 1"
        }
        if section == 2 {
            return "Platform \(platformsAndTrains[keys[1]]![0].nextEstimate[0].platform)"
        }
        if section == 3 {
            return "Platform \(platformsAndTrains[keys[2]]![0].nextEstimate[0].platform)"
        }
        return nil
    }

}
extension StationDetailViewController: mapViewDelegate, MKMapViewDelegate {
    func didPressButton() {
        if willShowRoute {
            // Remove Route
            customMapView.removeRoute()
            willShowRoute = false
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        } else {
            // Show Route
            customMapView.delegate = self
            let locationManager: CLLocationManager! = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            guard let _ = locationManager?.location else { return }
            customMapView.showsUserLocation = true
            customMapView.userTrackingMode = .follow
            customMapView.addLocation(stationInfo.location)
            customMapView.routeToDestination(stationInfo.location)
            willShowRoute = true
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyMarker"
                
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

//        annotationView?.glyphText = "😋"
        annotationView?.glyphImage = UIImage(systemName: "tram.fill")
        annotationView?.markerTintColor = UIColor.Custom.annotationBlue

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.Custom.annotationBlue
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

extension StationDetailViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.tableView.reloadSections(IndexSet(integersIn: 1...self.platformSections.count), with: .fade)
        }
    }
}
