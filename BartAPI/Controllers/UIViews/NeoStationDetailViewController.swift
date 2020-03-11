//
//  NeoStationDetailViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/9/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NeoStationDetailViewController: UIViewController {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var station: Station!
    
    var stationMap: NeoMap!
    
    var stationAddress: UILabel!
    var stationCity: UILabel!
    var findRouteButton: NeoButton!
    
    var platform1Label: UILabel!
    var platform1TableView: NeoTableView!
    var platform1Data = [EstimateDeparture]()
    
    var platform2Label: UILabel!
    var platform2TableView: NeoTableView!
    var platform2Data = [EstimateDeparture]()
    
    var platform3Label: UILabel!
    var platform3TableView: NeoTableView!
    var platform3Data = [EstimateDeparture]()
    
    let activityView: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer: Timer?


    override func viewDidLoad() {
        view.backgroundColor = UIColor.Custom.smokeWhite
        navigationController?.navigationBar.barTintColor = UIColor.Custom.smokeWhite
//        navigationItem.title = "HOME"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.barTintColor = UIColor.Custom.smokeWhite
        super.viewDidLoad()
        setUpScrollView()
        setUpMapAndAddress()
        setUpNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMap()
        setUpAddressComponet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start pulling platform data on different thread
        activityView.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            NetworkManager().eta.getEstimateTime(at: self.station.abbreviation, completion: { estimate, error in
                if let error = error {
                    print("ERROR WITH GETTING PLATFORM DATA: \(error)")
                    DispatchQueue.main.async {
                        self.activityView.stopAnimating()
                    }
                    return
                }
                if let estimate = estimate {
                    print("SUCCESS PULLING PLATFORM DATA")
                    self.seperatePlatforms(using: estimate.trains[0].estimate, completion: { complete in
                        if complete {
                            // Update Platform list
                            DispatchQueue.main.async {
                                self.activityView.stopAnimating()
                                self.setUpPlatforms()
                                self.createPlatformUpdateTimer()
                            }
                        }
                    })
                    return
                }
            })

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    fileprivate func setUpNavBar() {
        let activityIcon = UIBarButtonItem(customView: activityView)
        self.navigationItem.setRightBarButton(activityIcon, animated: true)
    }

    
    fileprivate func setUpMap() {
        stationMap.setUpNearest(nearestStation: station)
    }
    
    fileprivate func setUpScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
    
    fileprivate func setUpMapAndAddress() {
        // Station Map
        stationMap = NeoMap(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        stationMap.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stationMap)
        
        // Pin icon
        let pinIcon = UIImageView()
        pinIcon.image = UIImage(systemName: "mappin.and.ellipse")
        pinIcon.tintColor = .darkGray
        pinIcon.setContentHuggingPriority(.init(250.0), for: .horizontal)
        pinIcon.setContentHuggingPriority(.init(251.0), for: .vertical)
        pinIcon.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(pinIcon)
        
//         Address Stack
        let addressStack = UIStackView()
        addressStack.axis = .vertical
        addressStack.alignment = .leading
        addressStack.spacing = 0.0
        addressStack.setContentHuggingPriority(.init(251.0), for: .horizontal)
        addressStack.setContentHuggingPriority(.init(250.0), for: .vertical)
        addressStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(addressStack)

//         StationAddress Label
        stationAddress = UILabel()
//        stationAddress.text = "International Terminal, Level 3"
        stationAddress.numberOfLines = 0
        stationAddress.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        stationAddress.setContentHuggingPriority(.init(251.0), for: .horizontal)
        stationAddress.setContentHuggingPriority(.init(251.0), for: .vertical)
        stationAddress.setContentCompressionResistancePriority(.init(751.0), for: .vertical)
//        stationAddress.backgroundColor = .cyan
        addressStack.addArrangedSubview(stationAddress)

//         StationCity Label
        stationCity = UILabel()
//        stationCity.text = "San Francisco Int'l Airport, 94128"
        stationCity.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        stationCity.numberOfLines = 0
        stationCity.setContentHuggingPriority(.init(251.0), for: .horizontal)
        stationCity.setContentHuggingPriority(.init(251.0), for: .vertical)
//        stationCity.backgroundColor = .blue
        addressStack.addArrangedSubview(stationCity)
        
//         FindRoute Button
        findRouteButton = NeoButton()
        findRouteButton.setBackgroundImage(UIImage(systemName: "arrow.up.right.diamond.fill"), for: .normal)
        findRouteButton.setContentHuggingPriority(.init(252.0), for: .horizontal)
        findRouteButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(findRouteButton)

        
        
        NSLayoutConstraint.activate([
            // Station map
            stationMap.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 15),
            stationMap.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stationMap.widthAnchor.constraint(equalToConstant: 300),
            stationMap.heightAnchor.constraint(equalToConstant: 300),
            
            // PIN ICON
            pinIcon.heightAnchor.constraint(equalToConstant: 20.0),
            pinIcon.widthAnchor.constraint(equalToConstant: 20.0),
            pinIcon.topAnchor.constraint(equalTo: stationMap.bottomAnchor,constant: 15),
            pinIcon.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            // Address Stack
            addressStack.topAnchor.constraint(equalTo: stationMap.bottomAnchor,constant: 15),
            addressStack.leadingAnchor.constraint(equalTo: pinIcon.trailingAnchor, constant: 5),
            addressStack.trailingAnchor.constraint(greaterThanOrEqualTo: findRouteButton.leadingAnchor, constant: -15),
            
            // Route Button
            findRouteButton.heightAnchor.constraint(equalToConstant: 45.0),
            findRouteButton.widthAnchor.constraint(equalToConstant: 50.0),
            findRouteButton.topAnchor.constraint(equalTo: stationMap.bottomAnchor, constant: 15),
            findRouteButton.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        ])
    }
    
    fileprivate func seperatePlatforms(using trains: [EstimateDeparture], completion: @escaping (_ complete: Bool) -> ()) {
        // Dump data for refresh
        if !platform1Data.isEmpty {
            platform1Data.removeAll()
        }
        if !platform2Data.isEmpty {
            platform2Data.removeAll()
        }
        if !platform3Data.isEmpty {
            platform3Data.removeAll()
        }

        for train in trains {
            if train.nextEstimate[0].platform == "1" {
                platform1Data.append(train)
            }
            if train.nextEstimate[0].platform == "2" {
                platform2Data.append(train)
            }
            if train.nextEstimate[0].platform == "3" {
                platform3Data.append(train)
            }
        }
        print("Platform1Data: \(platform1Data)")
        print("Platform2Data: \(platform2Data)")
        print("Platform3Data: \(platform3Data)")
        completion(true)

    }
    
    fileprivate func setUpPlatforms() {
        // platform1 label
        platform1Label = UILabel()
        platform1Label.numberOfLines = 1
        platform1Label.text = "Platform 1"
        platform1Label.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        platform1Label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform1Label)
        if platform1Data.isEmpty {
            platform1Label.isHidden = true
        }

        // Platform 1 TableView
        platform1TableView = NeoTableView()
        platform1TableView.tableView.delegate = self
        platform1TableView.tableView.dataSource = self
        platform1TableView.tableView.isScrollEnabled = false
        platform1TableView.tableView.register(TrainArrivalsCell.self, forCellReuseIdentifier: "TrainArrivalsCell")
        platform1TableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform1TableView)
        
        // platform2 label
        platform2Label = UILabel()
        platform2Label.numberOfLines = 1
        platform2Label.text = "Platform 2"
        platform2Label.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        platform2Label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform2Label)
        if platform2Data.isEmpty {
            platform2Label.isHidden = true
        }

        
        // platform2 TableView
        platform2TableView = NeoTableView()
        platform2TableView.tableView.delegate = self
        platform2TableView.tableView.dataSource = self
        platform2TableView.tableView.isScrollEnabled = false
        platform2TableView.tableView.register(TrainArrivalsCell.self, forCellReuseIdentifier: "TrainArrivalsCell")
        platform2TableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform2TableView)
        
        // platform2 label
        platform3Label = UILabel()
        platform3Label.numberOfLines = 1
        platform3Label.text = "Platform 3"
        platform3Label.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        platform3Label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform3Label)
        if platform3Data.isEmpty {
            platform3Label.isHidden = true
        }
        
        // platform2 TableView
        platform3TableView = NeoTableView()
        platform3TableView.tableView.delegate = self
        platform3TableView.tableView.dataSource = self
        platform3TableView.tableView.isScrollEnabled = false
        platform3TableView.tableView.register(TrainArrivalsCell.self, forCellReuseIdentifier: "TrainArrivalsCell")
        platform3TableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(platform3TableView)
        
        NSLayoutConstraint.activate([
        // Platform 1 label
        platform1Label.topAnchor.constraint(equalTo: findRouteButton.bottomAnchor, constant: 10),
        platform1Label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        
        // Platform 1 Tableview
        platform1TableView.topAnchor.constraint(equalTo: platform1Label.bottomAnchor, constant: 10),
        platform1TableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        platform1TableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
        // Platform 2 label
        platform2Label.topAnchor.constraint(equalTo: platform1TableView.bottomAnchor, constant: 10),
        platform2Label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        
        // Platform 1 Tableview
        platform2TableView.topAnchor.constraint(equalTo: platform2Label.bottomAnchor, constant: 10),
        platform2TableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        platform2TableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
        // Platform 3 label
        platform3Label.topAnchor.constraint(equalTo: platform2TableView.bottomAnchor, constant: 10),
        platform3Label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        
        // Platform 1 Tableview
        platform3TableView.topAnchor.constraint(equalTo: platform3Label.bottomAnchor, constant: 10),
        platform3TableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        platform3TableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        scrollView.bottomAnchor.constraint(equalTo: platform3TableView.bottomAnchor, constant: 10)
        ])
    }
    
    fileprivate func createPlatformUpdateTimer() {
        let trainTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.timerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(trainTimer, forMode: .common)
        trainTimer.tolerance = 0.5
        self.timer = trainTimer
    }
    
    @objc func timerFunction() {
        self.activityView.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            NetworkManager().eta.getEstimateTime(at: self.station.abbreviation, completion: { estimate, error in
                if let error = error {
                    print("ERROR WITH GETTING PLATFORM DATA: \(error)")
                    DispatchQueue.main.async {
                        self.activityView.stopAnimating()
                    }
                    return
                }
                if let estimate = estimate {
                    print("SUCCESS PULLING PLATFORM DATA")
                    self.seperatePlatforms(using: estimate.trains[0].estimate, completion: { complete in
                        if complete {
                            // Update Platform list
                            DispatchQueue.main.async {
                                self.activityView.stopAnimating()
                                self.platform1TableView.tableView.reloadData()
                                self.platform2TableView.tableView.reloadData()
                                self.platform3TableView.tableView.reloadData()
                                self.adjustPlatformLabels()
                            }
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func adjustPlatformLabels() {
        if platform1Data.isEmpty {
            platform1Label.isHidden = true
        } else {
            platform1Label.isHidden = false
        }
        if platform2Data.isEmpty {
            platform2Label.isHidden = true
        } else {
            platform2Label.isHidden = false
        }
        if platform3Data.isEmpty {
            platform3Label.isHidden = true
        } else {
            platform3Label.isHidden = false
        }


    }
    
    fileprivate func setUpAddressComponet() {
        stationAddress.text = station.address
        stationCity.text = station.city
        findRouteButton.addTarget(self, action: #selector(openGoogleMaps), for: .touchUpInside)
    }
    
    @objc func openGoogleMaps() {
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(station.latitude),\(station.longitude)&directionsmode=driving")! as URL)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
        
    }
    
    fileprivate func formatDelayArrival(_ estimate: Estimate) -> NSAttributedString {
        var normalArrival: String
        var normalAttributes: [NSAttributedString.Key: NSObject]
        switch estimate.arrival {
           case "Leaving", "leaving":
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
                case "Leaving", "leaving":
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
    
    // Pull platform train data on seperate thread
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NeoStationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.platform1TableView.tableView {
            print("Plaform 3 count: \(platform3Data.count)")
            return platform1Data.count
        }
        if tableView == self.platform2TableView.tableView {
            print("Plaform 3 count: \(platform3Data.count)")
            return platform2Data.count
        }
        if tableView == self.platform3TableView.tableView {
            print("Plaform 3 count: \(platform3Data.count)")
            return platform3Data.count
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.platform1TableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainArrivalsCell",for: indexPath) as! TrainArrivalsCell
            print("LOOKING AT: \(platform1Data[indexPath.row])")
            let train = platform1Data[indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            
            cell.destinationName.text = train.destination
            var foundDelay = false
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in train.nextEstimate {
                if train.isDelayed() {
                    print("Found delay with : \(train)")
                    foundDelay = true
                    break findDelay
                }
            }
            
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            switch train.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.text = nil

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(train.nextEstimate[2])

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            }

            cell.backgroundColor = UIColor.Custom.smokeWhite
            return cell
        }
        if tableView == self.platform2TableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainArrivalsCell",for: indexPath) as! TrainArrivalsCell
            print("LOOKING AT: \(platform2Data[indexPath.row])")
            let train = platform2Data[indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            
            cell.destinationName.text = train.destination
            var foundDelay = false
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in train.nextEstimate {
                if train.isDelayed() {
                    foundDelay = true
                    break findDelay
                }
            }
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            switch train.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.text = nil

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(train.nextEstimate[2])

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            }
            cell.backgroundColor = UIColor.Custom.smokeWhite
            return cell

        }
        if tableView == self.platform3TableView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainArrivalsCell",for: indexPath) as! TrainArrivalsCell
            print("LOOKING AT: \(platform3Data[indexPath.row])")
            let train = platform3Data[indexPath.row]
            let color = UIColor.BARTCOLORS(rawValue: train.nextEstimate[0].color)
            cell.routeColorView.backgroundColor = color?.colors
            
            cell.destinationName.text = train.destination
            var foundDelay = false
            // By adding a label, we can break out of the whole loop when a single delay has been found.
            findDelay:
            for train in train.nextEstimate {
                if train.isDelayed() {
                    foundDelay = true
                    break findDelay
                }
            }
            cell.delayArrivalTitle.attributedText = cell.setUpTitle(delay: foundDelay)
            switch train.nextEstimate.count {
            case 1:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            case 2:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.text = nil

            case 3:
                cell.firstTime.attributedText = formatDelayArrival(train.nextEstimate[0])
                cell.secondTime.attributedText = formatDelayArrival(train.nextEstimate[1])
                cell.thirdTime.attributedText = formatDelayArrival(train.nextEstimate[2])

            default:
                cell.firstTime.text = " "
                cell.secondTime.text = " "
                cell.thirdTime.text = " "

            }
            cell.backgroundColor = UIColor.Custom.smokeWhite
            return cell
        }

        return UITableViewCell()
    }
}
