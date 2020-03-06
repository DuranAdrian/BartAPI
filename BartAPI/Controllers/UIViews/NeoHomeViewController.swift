//
//  NeoHomeViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/2/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NeoHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // ScrollView
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MapKit
    var circularMap: NeoMap!
    fileprivate lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    // TableViews with 1 label
    var nearestStationTableView: NeoTableView!
    var nextTrainLabel: UILabel!
    var nextTrainsTableView: NeoTableView!
    
    // Network Layer
    private let networkManager = NetworkManager()
    
    // Activity Monitor for Network Calls
    fileprivate var activityMonitorView = UIActivityIndicatorView()
    
    // List of all Stations intialize as nil
    private var stationList: [Station]? = nil
    
    // Advisory Pop Up
    private var advisoryPopUp: AdvisoryPopUp!
    private var previousAdvisory: Advisory!
    private var hideAdvisoryConstraint: NSLayoutConstraint!
    private var showAdvisoryConstraint: NSLayoutConstraint!
    private var blurEffectView: UIVisualEffectView!
    
    // Closest Station - Can be nil
    private var closestStation: Station?
    
    // Closest Station Distance - Can be nil
    private var closestDistance: CLLocationDistance?
    
    // Next directional trains for found closest station
    private var nextNorthTrain: EstimateDeparture?
    private var nextSouthTrain: EstimateDeparture?
    private var nextTrainTimer: Timer?

    // MARK: - ViewSetUp
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Custom.smokeWhite
        print("View did load")
        
        // Pull Station List Data
        DispatchQueue.global(qos: .userInteractive).async {
            print("Pulling station list")
            self.pullStationList(completion: { completion in
                // If successfull, load stationlist and check permissions to see if closest station is near
                if completion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                        print("Completed userInteractive Thread")
                        let stationList = UserDefaults.standard.value(forKey: "StationList") as! Data
                        self.stationList = try? PropertyListDecoder().decode(Array<Station>.self, from: stationList)
                        self.locationManager.delegate = self
                        self.activityMonitorView.stopAnimating()
                    })
                } else {
                    // Failed to pull stations due to connection issue. Cannot set stationList
                    // check permissions
                    DispatchQueue.main.async {
                        self.locationManager.delegate = self
                        self.activityMonitorView.stopAnimating()
                    }
                }
                // Start pulling Advisory Data Regardless of station list status
                self.startAdvisories()
            })
        }
        
        setUpTabBar()
        setUpNavBar()
        setUpScrollView()
        setUpComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")
        // Update data with Up To Data train data

    }

    private func setUpTabBar() {
        tabBarController?.tabBar.barTintColor = UIColor.Custom.smokeWhite
    }
    
    private func setUpNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.Custom.smokeWhite
        navigationItem.title = "HOME"
        let activityIcon = UIBarButtonItem(customView: activityMonitorView)
        self.navigationItem.setRightBarButton(activityIcon, animated: true)
    }
    
    private func setUpScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setUpComponents() {
        // Add CircularMap
        circularMap = NeoMap(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        circularMap.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(circularMap)
        
        // Add Nearest Station
        nearestStationTableView = NeoTableView()
        nearestStationTableView.tableView.delegate = self
        nearestStationTableView.tableView.dataSource = self
        nearestStationTableView.isUserInteractionEnabled = false
        nearestStationTableView.tableView.register(NearestStationCell.self, forCellReuseIdentifier: "NearestStationCell")
        nearestStationTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nearestStationTableView)
        
        // NextTrainLabel
        nextTrainLabel = UILabel()
        nextTrainLabel.text = "Next Arriving Train"
        nextTrainLabel.numberOfLines = 1
        nextTrainLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        nextTrainLabel.translatesAutoresizingMaskIntoConstraints = false
        nextTrainLabel.isHidden = true
        scrollView.addSubview(nextTrainLabel)
        
        // Add NextTrains
        nextTrainsTableView = NeoTableView()
        nextTrainsTableView.tableView.delegate = self
        nextTrainsTableView.tableView.dataSource = self
        nextTrainsTableView.isUserInteractionEnabled = false
        nextTrainsTableView.tableView.register(NextTrainCell.self, forCellReuseIdentifier: "NextTrainCell")
        nextTrainsTableView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(nextTrainsTableView)

        
        NSLayoutConstraint.activate([
            // CircularMap
            circularMap.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            circularMap.centerXAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.centerXAnchor),
            circularMap.widthAnchor.constraint(equalToConstant: 300),
            circularMap.heightAnchor.constraint(equalToConstant: 300),
            
            // Nearest Station
            nearestStationTableView.topAnchor.constraint(equalTo: circularMap.bottomAnchor, constant: 50),
            nearestStationTableView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            nearestStationTableView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            // Next Train Label
            nextTrainLabel.topAnchor.constraint(equalTo: nearestStationTableView.bottomAnchor, constant: 20),
            nextTrainLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            // Next Trains
            nextTrainsTableView.topAnchor.constraint(equalTo: nextTrainLabel.bottomAnchor, constant: 10),
            nextTrainsTableView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            nextTrainsTableView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextTrainsTableView.bottomAnchor, constant: 10)
        ])
    }
    
    private func hideTableViews() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            nextTrainLabel.isHidden = true
            nearestStationTableView.isHidden = true
            nextTrainsTableView.isHidden = true
        }
    }
    
    // MARK: - Advisory
    
    private func startAdvisories() {
        // THIS FUNCTION GETS CALLED IN VIEW DID LOAD, WILL ALWAYS BE IN SOME KIND OF BACKGROUND THREAD, NOT MAIN
        print("Pulling Advisories")
        networkManager.advisories.getAdvisory(completion: { advisory, error in
            if let error = error {
                print("Could not get advisory data: \(error)")
                Thread.current.cancel()
            }
            
            if let advisory = advisory {
                // Only show the same advisory once
                // Check if advisory has been shown
                if (self.showAdvisoryConstraint?.isActive) != nil {
                    // Since showAdvisoryContraint is not nil, an advisory has already been shown
                    if advisory == self.previousAdvisory {
                        // Don't show same advisory
                        return
                    } else {
                        // Advisory is different
                        self.previousAdvisory = advisory
                        
                        if self.showAdvisoryConstraint.isActive {
                            // There is is currently an active advisory popup
                            return
                        } else {
                            // Advisory has changed
                            DispatchQueue.main.async {
                                self.createAdvisory(advisory)
                            }
                        }
                    }
                } else {
                    // First time showing Advisory
                    self.previousAdvisory = advisory
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.createAdvisory(advisory)
                    })
                }
            }
            
        })
    }
    
    private func createAdvisory(_ adv: Advisory) {
        // Add Blur Background
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.0
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(blurEffectView)

        // Add PopUp on top of view
        advisoryPopUp = AdvisoryPopUp()
        advisoryPopUp.layer.borderColor = UIColor.Custom.annotationBlue.cgColor
        advisoryPopUp.layer.backgroundColor = UIColor.Custom.errorRed.cgColor
        advisoryPopUp.layer.borderWidth = 1.0
        advisoryPopUp.layer.cornerRadius = 15.0
        advisoryPopUp.layer.masksToBounds = true
        advisoryPopUp.setMessage(message: adv.bsa[0].description)
        scrollView.addSubview(advisoryPopUp)
        
        // Set Leading and Trailing Anchors
        advisoryPopUp.translatesAutoresizingMaskIntoConstraints = false
        advisoryPopUp.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        advisoryPopUp.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        hideAdvisoryConstraint = advisoryPopUp.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        hideAdvisoryConstraint.isActive = true
        scrollView.layoutIfNeeded()
        
        // Show Advisory
        hideAdvisoryConstraint.isActive = false
        showAdvisoryConstraint = advisoryPopUp.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        showAdvisoryConstraint.isActive = true
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
            self.blurEffectView.alpha = 0.75
            self.scrollView.layoutIfNeeded()
            
        }, completion: { _ in
            // Create timer to hide
            self.createAdvisoryTimer()
        })


    }
    
    @objc func removeAdvisory() {
        // Check if user already dimissed view.
        if self.showAdvisoryConstraint.isActive {
            showAdvisoryConstraint.isActive = false
            hideAdvisoryConstraint.isActive = true
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                self.blurEffectView.alpha = 0.0
                self.scrollView.layoutIfNeeded()
            }, completion: { _ in
                self.advisoryPopUp.removeFromSuperview()
                self.blurEffectView.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Timers
    private func createAdvisoryTimer() {
        // Since repeat is false, it will invalidate itself once complete.
        let advTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(removeAdvisory), userInfo: nil, repeats: false)
        RunLoop.current.add(advTimer, forMode: .common)
        advTimer.tolerance = 5.0
    }

    // CREATE TIMER TO ATTACH TO PULLING NEXT TRAIN AND ADVISORY EVERY 30 SECONDS
    private func createNextTrainsTimer() {
        print("CREATING TRAIN TIMER")
        let initTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateDataTimerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(initTimer, forMode: .common)
        initTimer.tolerance = 0.5
        self.nextTrainTimer = initTimer
    }
    
    @objc private func updateDataTimerFunction() {
        print("Creating timer function")
        DispatchQueue.main.async {
            self.activityMonitorView.startAnimating()
        }
        // Ensure current station is valid
        if let station = closestStation {
            // Create dispatch group to update both next North Train and South Train before updating tableview in one statement
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1.0, execute: {
                let group = DispatchGroup()
                // Pull next North Train
                group.enter()
                self.networkManager.eta.getFirstNorthTrain(to: station.abbreviation, completion: { estimate, error in
                    if let error = error {
                        print("Error updating first North train: \(error)")
//                        DispatchQueue.main.async {
//                            self.activityMonitorView.stopAnimating()
//                        }
                        group.leave()
                    }
                    if let estimate = estimate {
                        print("SUCCESSFULL NEXT NORTH ESTIMATE")
                        self.nextNorthTrain = estimate
                        group.leave()
                    }
                })
                
                // Pull next South Train
                group.enter()
                self.networkManager.eta.getFirstSouthTrain(to: station.abbreviation, completion: { estimate, error in
                    if let error = error {
                        print("Error updating first South Train: \(error)")
                        group.leave()
                    }
                    if let estimate = estimate {
                        print("SUCCESSFULL NEXT SOUTH ESTIMATE")
                        self.nextSouthTrain = estimate
                        group.leave()

                    }
                })
                group.enter()
                // Pull Advisory Data
                self.networkManager.advisories.getAdvisory(completion: { advisory, error in
                    if let error = error {
                        print("Error updating Advisory: \(error)")
                        group.leave()
                    }
                    if let advisory = advisory {
                        // Check if advisory has been shown
                        print("Updated Advisory")
                        print(advisory)
                        if (self.showAdvisoryConstraint?.isActive) != nil {
                            // Since showAdvisoryContraint is not nil, an advisory has already been shown
                            if advisory == self.previousAdvisory {
                                // Don't show same advisory
                                print("Advisory is the same")
                                group.leave()
                                return
                            } else {
                                // Advisory is different
                                self.previousAdvisory = advisory
                                
                                if self.showAdvisoryConstraint.isActive {
                                    // There is is currently an active advisory popup
                                    print("Advisory is currently active")
                                    group.leave()
                                    return
                                } else {
                                    // Advisory has changed
                                    print("Advisory is new")
                                    DispatchQueue.main.async {
                                        self.createAdvisory(advisory)
                                    }
                                    group.leave()
                                }
                            }
                        } else {
                            // First time showing Advisory
                            self.previousAdvisory = advisory
                            DispatchQueue.main.async {
                                self.createAdvisory(advisory)
                            }
                            group.leave()
                        }
                    }
                })
                
                group.notify(queue: .main) { [weak self] in
                    print("UPDATING VIEW")
                    self?.nextTrainLabel.isHidden = false
                    self?.nextTrainsTableView.isHidden = false
                    self?.nextTrainsTableView.tableView.reloadSections([0], with: .fade)
                    self?.nextTrainsTableView.invalidateIntrinsicContentSize()
                    self?.activityMonitorView.stopAnimating()
                }
            })
        }
    }
    
    // MARK: - HelperFunctions
    /*
     Find if user has already pulled Station list in User Defaults.
     Since each Station is 152 Btyes (9 String Variabls at 16 bytes each, 1 CLLocation Variable
     at 8 bytes) and there will be 48 Stations, 48 * 152 = 7,296 Bytes.
     I want to minimize my Network calls, so for now, I will be storing Station list in
     User Defaults. Maybe later on will store off Device in a database such as Firebase.
    */
    private func pullStationList(completion: @escaping (_ complete: Bool) -> Void) {
        
        if UserDefaults.standard.object(forKey: "stationList") != nil {
            // Station list has already been pulled and stored
            print("User Defaults already exist")
            completion(true)
            return
        } else {
            DispatchQueue.main.async {
                self.activityMonitorView.startAnimating()
            }
            // Pull Data and Store in User Defaults
            networkManager.stations.getStationList(completion: { stations, error in
                if let error = error {
                    print("ERROR: \(error)")
                    completion(false)
                    return
                }
                if let stations = stations {
                    print("Succesful stationList data pull")
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(stations), forKey: "StationList")
                    completion(true)
                }
            })
        }
    }
    
    private func findNearestStation(completion: @escaping (_ complete: Bool) -> Void) {
    
        guard let userLocation = CLLocationManager().location else {
            print("Cannot find user location")
            completion(false)
            return
        }
        
        var closestStation: Station?
        var smallestDistance: CLLocationDistance?
        
        if let stations = self.stationList {
            for station in stations {
                let distance = userLocation.distance(from: station.location)
                if smallestDistance == nil || distance < smallestDistance! {
                    closestStation = station
                    smallestDistance = distance
                }
            }
            self.closestStation = closestStation
            self.closestDistance = smallestDistance
            completion(true)
            return
        }
        completion(false)
    }
    
    // MARK: - Formatting Functions
    
    func convertMetersToMiles(_ distance: Double) -> String {
        return String(format: "%.2f", ((distance / 1000.0 ) * 0.62137))
    }
    
    // MARK: - Permissions

    func checkLocationPermissions() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location Authorized")
            if let list = stationList {
                circularMap.setUpRestrictiveMap(listOfStations: list)
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.findNearestStation(completion: { complete in
                    if complete {
                        DispatchQueue.main.async {
                            self.nearestStationTableView.isHidden = false
                            self.nearestStationTableView.tableView.reloadData()
                            self.nearestStationTableView.invalidateIntrinsicContentSize()
                            
                            // Ensure station exist
                            if let station = self.closestStation {
                                self.circularMap.setUpNearest(nearestStation: station)
                                self.activityMonitorView.startAnimating()
                                DispatchQueue.global(qos: .userInitiated).async {
                                    let group = DispatchGroup()
                                    group.enter()
                                    self.networkManager.eta.getFirstNorthTrain(to: station.abbreviation, completion: {
                                        estimate, error in
                                        if let error = error {
                                            print("Error getting first North train: \(error)")
                                            group.leave()
                                        }
                                        if let estimate = estimate {
                                            print("SUCCESSFULL NEXT NORTH ESTIMATE")
                                            self.nextNorthTrain = estimate
                                            group.leave()
                                        }
                                    })
                                    group.enter()
                                    self.networkManager.eta.getFirstSouthTrain(to: station.abbreviation, completion: { estimate, error in
                                        if let error = error {
                                            print("Error getting first South train: \(error)")
                                            group.leave()
                                        }
                                        if let estimate = estimate {
                                            print("SUCCESSFULL NEXT SOUTH ESTIMATE")
                                            self.nextSouthTrain = estimate
                                            group.leave()
                                        }
                                    })
                                    group.notify(queue: .main) { [weak self] in
                                        self?.nextTrainLabel.isHidden = false
                                        self?.nextTrainsTableView.isHidden = false
                                        self?.nextTrainsTableView.tableView.reloadSections([0], with: .fade)
                                        self?.nextTrainsTableView.invalidateIntrinsicContentSize()
                                        self?.activityMonitorView.stopAnimating()
                                        self?.createNextTrainsTimer()
                                    }
                                }
                            }
                        }
                    } else {
                        // Cannot find user location
                        print("Cannot find user location or Station list")
                    }
                })
            }

            break
        case .denied:
            print("denied")
            if let list = stationList {
                circularMap.setUpRestrictiveMap(listOfStations: list)
            }
            showPrivacyAlert()
            break
        case .notDetermined:
            print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
            if let list = stationList {
                circularMap.setUpRestrictiveMap(listOfStations: list)
            }
            hideTableViews()
            break
        case .restricted:
            print("Restricted")
            if let list = stationList {
                circularMap.setUpRestrictiveMap(listOfStations: list)
            }
//            showEnableLocationAlert()
            break
        @unknown default:
            print("Unknown permission")
            locationManager.requestWhenInUseAuthorization()
            if let list = stationList {
                circularMap.setUpRestrictiveMap(listOfStations: list)
            }
            break
        }
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.nearestStationTableView.tableView {
            if let _ = closestStation {
                // There does exist a closest Station
                return 68.0
            }
            return 0.0
        }
        
        if tableView == self.nextTrainsTableView.tableView {
            if indexPath.row == 0 {
                // Next North Train
                if let _ = nextNorthTrain {
                    // There does exist a next North Train
                    return 63.0
                } else {
                    return 0.0
                }
            } else {
                // Next South Train
                if let _ = nextSouthTrain {
                    // There does exist a next South Train
                    return 63.0
                } else {
                    return 0.0
                }
            }
        }

        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.nearestStationTableView.tableView {
            if let _ = closestStation {
                // There does exist a closest Station
                return 68.0
            }
            return 0.0
        }
        
        if tableView == self.nextTrainsTableView.tableView {
            if indexPath.row == 0 {
                // Next North Train
                if let _ = nextNorthTrain {
                    // There does exist a next North Train
                    return 63.0
                } else {
                    return 0.0
                }
            } else {
                // Next South Train
                if let _ = nextSouthTrain {
                    // There does exist a next South Train
                    return 63.0
                } else {
                    return 0.0
                }
            }
        }

        return 0.0

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.nearestStationTableView.tableView {
            return 1
        }
        if tableView == self.nextTrainsTableView.tableView {
            return 2
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.nearestStationTableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStationCell") as! NearestStationCell
            cell.backgroundColor = UIColor.Custom.smokeWhite
            
            if let closestStation = closestStation {
                cell.stationName.text = closestStation.name
            } else {
                cell.stationName.text = ""
            }
            
            if let closestDistance = closestDistance {
                cell.stationDistance.text = convertMetersToMiles(closestDistance) + " Miles"
            } else {
                cell.stationDistance.text = ""
            }
            
            return cell
        }
        if tableView == self.nextTrainsTableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextTrainCell", for: indexPath) as! NextTrainCell
            cell.backgroundColor = UIColor.Custom.smokeWhite
            if indexPath.row == 0 {
                // As we are dealing with multiple threads, Ensure that there is a next North Train
                if let nextTrain = nextNorthTrain {
                    cell.routeDirection.text = "North"
                    cell.destination.text = nextTrain.destination
                    let color = UIColor.BARTCOLORS(rawValue: nextTrain.nextEstimate[0].color)
                    cell.routeColorView.backgroundColor = color?.colors
                    cell.estimatedTimeArrival.text = nextTrain.nextEstimate[0].computeTrainETA()
                    cell.arrivingInLabel.attributedText = cell.setArrivalTitle(train: nextTrain.nextEstimate[0])
                    return cell
                }
                return cell
            } else {
                // As we are dealing with multiple threads, Ensure that there is a next South Train
                if let nextTrain = nextSouthTrain {
                    cell.routeDirection.text = "South"
                    cell.destination.text = nextTrain.destination
                    let color = UIColor.BARTCOLORS(rawValue: nextTrain.nextEstimate[0].color)
                    cell.routeColorView.backgroundColor = color?.colors
                    cell.estimatedTimeArrival.text = nextTrain.nextEstimate[0].computeTrainETA()
                    cell.arrivingInLabel.attributedText = cell.setArrivalTitle(train: nextTrain.nextEstimate[0])
                    return cell
                }
                return cell
            }
        }
        let cell = UITableViewCell()
        cell.isHidden = true
        cell.backgroundColor = UIColor.Custom.smokeWhite
        return cell
    }
}

extension NeoHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationPermissions()
    }
}
