//
//  NeoMap.swift
//  Project1
//
//  Created by Adrian Duran on 2/22/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit


class NeoMap: UIView, MKMapViewDelegate, CLLocationManagerDelegate {
    let smokeWhite = UIColor.Custom.smokeWhite
    let map = MKMapView()
    fileprivate var locationManager: CLLocationManager! = CLLocationManager()
    private var closestStation: Station!
    
    var showUserLocation: Bool = true
    // Flags
    var showingAllStations: Bool = false
    var showingRoute: Bool = false
    var isFullScreen: Bool = false
    
    lazy var topLeftShadow = CALayer()
    lazy var bottomRightShadow = CALayer()
    var originalCornerRadius: CGFloat!
    
    // Buttons for fullScreen
    private var menuButton: UIButton!
    // Button 1
    private let button1 = UIButton()
    private var button1Trailing: NSLayoutConstraint!
    private var showButton1Trailing: NSLayoutConstraint!
    // Button 2
    private let button2 = UIButton()
    private var button2Trailing: NSLayoutConstraint!
    private var button2Bottom: NSLayoutConstraint!
    private var showButton2Trailing: NSLayoutConstraint!
    private var showButton2Bottom: NSLayoutConstraint!
    // Button 3
    private let button3 = UIButton()
    private var button3Bottom: NSLayoutConstraint!
    private var showButton3Bottom: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCircularMap()
        addShadows()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCircularMap()
        addShadows()
    }
    
    
    func setUpCircularMap() {
        // WILL BE COMPOSED OF 4 THINGS: MAP, CIRCLE BORDER, AND 2 SHADOWS
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = false
//        clipsToBounds = false
        layer.backgroundColor = smokeWhite.cgColor
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.white.cgColor
        // add map
        map.frame = bounds
        map.layer.cornerRadius = frame.size.width / 2
        originalCornerRadius = map.layer.cornerRadius
        map.clipsToBounds = true
        map.delegate = self
        
        // SET DEFAULT MAP TO BAY AREA
        centerOnBayArea()
        addSubview(map)
        
        map.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: topAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        map.isUserInteractionEnabled = false
        
    }
    
    fileprivate func addShadows() {
        topLeftShadow = CALayer()
        topLeftShadow.backgroundColor = UIColor.Custom.smokeWhite.cgColor
        topLeftShadow.cornerRadius = frame.size.width / 2
        topLeftShadow.shadowOpacity = 1.0
        topLeftShadow.shadowRadius = 7.5
        topLeftShadow.shadowColor = UIColor.white.cgColor
        topLeftShadow.shadowOffset = CGSize(width: -5, height: -5)
        topLeftShadow.masksToBounds = false
        
        
        bottomRightShadow = CALayer()
        bottomRightShadow.backgroundColor = UIColor.Custom.smokeWhite.cgColor
        bottomRightShadow.cornerRadius = frame.size.width / 2
        bottomRightShadow.shadowOpacity = 1.0
        bottomRightShadow.shadowRadius = 6.0
        bottomRightShadow.shadowColor = UIColor.lightGray.cgColor
        bottomRightShadow.shadowOffset = CGSize(width: 5, height: 8)
        bottomRightShadow.masksToBounds = false

    }
    
    func showUser() {
        // Maybe redundent, but double check if locations are enabled
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    // Show Alert to user - enable location
                return
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                zoomInOnUser()
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
                // Show Alert to user - enable location
        }

    }
    // Center and Zooms in on user
    func zoomInOnUser() {
        map.userTrackingMode = .follow
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLDistanceFilterNone
        
        guard let location = locationManager.location else { print("ERROR - Could not zoom in on user"); return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion.init(center: location.coordinate, span: span)
        map.setRegion(region, animated: true)
    }
    
    // Center Map with current span on user
    func centerOnUser() {
        guard let location = locationManager.location else { print("ERROR - Could not center map on user"); return }
        
        let region = MKCoordinateRegion.init(center: location.coordinate, span: map.region.span)
        map.setRegion(region, animated: true)

    }
    
    func centerOnBayArea() {
        let location = CLLocationCoordinate2D(latitude: 37.8272,
        longitude: -122.2913)
         
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func setUpRestrictiveMap(listOfStations: [Station]) {
        // Ensure listOfStations array is not empty else set up CenterOnBayArea
        if listOfStations.isEmpty {
            print("List of station is empty, Centering on bay area")
            centerOnBayArea()
            return
        }
        // Assumes there are valid items in listOfStations
        var zoomRect = MKMapRect.null
        
        let annotations = listOfStations.map { station -> MKAnnotation in
            // Create annotation
            let annotation = MKPointAnnotation()
            annotation.title = station.name
            annotation.coordinate = station.location.coordinate
            
            //Get rect for zooming purposes
            let stationPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: stationPoint.x, y: stationPoint.y, width: 1.0, height: 1.0)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
            
            return annotation
        }
        self.map.addAnnotations(annotations)
        // Add Padding to show all Stations Available as best as visually possible
        self.map.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 66, left: 44, bottom: 44, right: 66 ), animated: true)
    }
    
    // SHOWS NEAREST STATION ON MAP WITH CURRENT LOCATION - Normal Mode on
    
    func addNearestStation() {
        // find user location
        
    }
    
    func setUpNearest(nearestStation: Station){
        closestStation = nearestStation
        if !self.map.annotations.isEmpty {
            print("Map annotations are not empty")
            // Remove current annotations
            UIView.animate(withDuration: 1.5, animations: {
                for annotation in self.map.annotations {
                    if annotation.title != nearestStation.name {
                        self.map.view(for: annotation)?.alpha = 0.0
                    }
                }
            }, completion: { _ in
                print("Removing annotations")
                self.map.removeAnnotations(self.map.annotations)
                print("Adding closest Station")
                // Add closest station once complete
                self.addClosestStation(nearestStation: nearestStation)
            })
        } else {
            print("No Annotations detected")
            self.addClosestStation(nearestStation: nearestStation)
        }
    }
    
    // Helper method for setUpNearest
    func addClosestStation(nearestStation: Station){
        // use nearestStation to create annotation and add
        let annotation = MKPointAnnotation()
        annotation.title = nearestStation.name
        annotation.coordinate = nearestStation.location.coordinate

        self.map.addAnnotation(annotation)
    
        // Get user location and set up
        guard let _ = CLLocationManager().location else { return }
        CLLocationManager().startUpdatingLocation()
        self.map.showsUserLocation = true
        // Due to the way GPS works. need to add a very slight delay to get initial current location before displaying correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.fitVisualMap() })

        /* Route Begin
        // set up route
        let sourceLocation = MKMapItem.forCurrentLocation()
        let destinationLocation = MKMapItem(placemark: MKPlacemark(coordinate: (CLLocationCoordinate2D(latitude: nearestStation.location.coordinate.latitude, longitude: nearestStation.location.coordinate.longitude))))
        
        // Route request
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceLocation
        directionRequest.destination = destinationLocation
        directionRequest.transportType = .automobile
        
        // Calculate route path
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {(response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error with route overlay: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            var zoomRect = MKMapRect.null
            print("ALL ANNOTATIONS IN CLOSEST STATION")
            for annotation in self.map.annotations {
                print(annotation)
                let annoPoint = MKMapPoint(annotation.coordinate)
                let rect = MKMapRect(x: annoPoint.x, y: annoPoint.y, width: 1.0, height: 1.0)
                
                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            zoomRect = zoomRect.union(rect)
            let padding = UIEdgeInsets(top: 66.0, left: 44.0, bottom: 44.0, right: 66.0)
            let biggerRect = self.map.mapRectThatFits(zoomRect, edgePadding: padding)
            self.map.setRegion(MKCoordinateRegion(biggerRect), animated: true)
        })
        Route end*/
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topLeftShadow.frame = bounds
        layer.insertSublayer(topLeftShadow, at: 0)
        
        bottomRightShadow.frame = bounds
        layer.insertSublayer(bottomRightShadow, at: 0)
    }
    
    func fitVisualMap() {
        // check if notations already exist
        if self.map.annotations.isEmpty {
            print("No Annotations")
            return
        } else {
            print("Found annotations")
            var zoomRect = MKMapRect.null
            var rect = MKMapRect()
            for annotation in self.map.annotations {
                let annoPoint = MKMapPoint(annotation.coordinate)
                rect = MKMapRect(x: annoPoint.x, y: annoPoint.y, width: 1.0, height: 1.0)
                
                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            
            zoomRect = zoomRect.union(rect)
            let padding = UIEdgeInsets(top: 66.0, left: 44.0, bottom: 44.0, right: 66.0)
            let biggerRect = self.map.mapRectThatFits(zoomRect, edgePadding: padding)
            self.map.setRegion(MKCoordinateRegion(biggerRect), animated: true)
        }
        print("Number of annotations:\(self.map.annotations.count)")
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

        annotationView?.glyphImage = UIImage(systemName: "tram.fill")
        annotationView?.markerTintColor = UIColor.Custom.annotationBlue
        annotationView?.displayPriority = .required
        annotationView?.alpha = 1.0
        annotationView?.isEnabled = false

        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.Custom.annotationBlue
        renderer.lineWidth = 4.0
        
        return renderer
    }

    // MARK: - MAP BUTTONS
    func addButtonsToCorner() {
        let buttonWidth = 55.0
        menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        menuButton.addTarget(self, action: #selector(add3buttons), for: .touchUpInside)
        menuButton.titleLabel?.textColor = .white
//        menuButton.setTitle("Tap", for: .normal)
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.imageView?.tintColor = .white
        menuButton.backgroundColor = .darkGray
        print("Button frame size: \(menuButton.frame.size)")
        menuButton.layer.cornerRadius = menuButton.frame.size.width / 2
        menuButton.layer.masksToBounds = false
//        button.clipsToBounds = true
        map.addSubview(menuButton)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.trailingAnchor.constraint(equalTo: map.trailingAnchor, constant: -20).isActive = true
        menuButton.bottomAnchor.constraint(equalTo: map.bottomAnchor, constant: -20).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: CGFloat(buttonWidth)).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: CGFloat(buttonWidth)).isActive = true
    }
    // Menu button
    
    @objc func add3buttons() {
        // Try to add under the menubutton instead of on top
        print("adding 3 buttons...")
        let buttonWidth = 40.0
        let menuFrame = menuButton.frame
        
        let buttons = [button1, button2, button3]
        
        for button in buttons {
            button.frame = CGRect(x: menuFrame.origin.x, y: menuFrame.origin.y, width: CGFloat(buttonWidth), height: CGFloat(buttonWidth))
            button.layer.cornerRadius = button.frame.size.width / 2
            button.layer.masksToBounds = false
            button.translatesAutoresizingMaskIntoConstraints = false
            // Add Behind Menu Button
            map.insertSubview(button, belowSubview: menuButton)
            // Height and width will remain the same for all buttons
            button.heightAnchor.constraint(equalToConstant: CGFloat(buttonWidth)).isActive = true
            button.widthAnchor.constraint(equalToConstant: CGFloat(buttonWidth)).isActive = true
            button.alpha = 0.0
        }
        // Temporary background colors to distinguish
        // Button 1 will show route
        button1.backgroundColor = UIColor.Custom.annotationBlue
        button1.setImage(UIImage(systemName: "arrow.up.right.diamond.fill"), for: .normal)
        button1.imageView?.tintColor = .white
        button1.addTarget(self, action: #selector(showRoute2), for: .touchUpInside)
        // Button 2 will show all stations and disable route
        button2.backgroundColor = UIColor.Custom.mapRed
        button2.setImage(UIImage(systemName: "mappin.circle"), for: .normal)
        button2.imageView?.tintColor = .white
        button2.addTarget(self, action: #selector(showAllStations), for: .touchUpInside)
        // Button 3 will open google maps to give turn by turn navigation
        button3.backgroundColor = UIColor.Custom.mapGreen
        button3.setImage(UIImage(systemName: "map.fill"), for: .normal)
        button3.imageView?.tintColor = .white
        button3.addTarget(self, action: #selector(openGoogleMaps), for: .touchUpInside)
        
        // Set InitialContraints For all 3 buttons
        // Button 1 Initial Contraints
        button1Trailing = button1.trailingAnchor.constraint(equalTo: menuButton.trailingAnchor)
            button1Trailing.isActive = true
        let button1Bottom = button1.bottomAnchor.constraint(equalTo: menuButton.bottomAnchor)
            button1Bottom.isActive = true
        
        // Button 2 Initial Contraints
        button2Trailing = button2.trailingAnchor.constraint(equalTo: menuButton.trailingAnchor)
            button2Trailing.isActive = true
        button2Bottom = button2.bottomAnchor.constraint(equalTo: menuButton.bottomAnchor)
            button2Bottom.isActive = true
        
        // Button 3 Initial Contraints
        let button3Trailing = button3.trailingAnchor.constraint(equalTo: menuButton.trailingAnchor)
            button3Trailing.isActive = true
        button3Bottom = button3.bottomAnchor.constraint(equalTo: menuButton.bottomAnchor
        )
            button3Bottom.isActive = true


        
        // Button 1 final position - left side
        button1Trailing.isActive = false
        showButton1Trailing = button1.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -15)
        showButton1Trailing.isActive = true
        
        // Button 3 final position - top side
        button3Bottom.isActive = false
        showButton3Bottom = button3.bottomAnchor.constraint(equalTo: menuButton.topAnchor, constant: -15)
        showButton3Bottom.isActive = true
        
        // Button 2 final position - top left
        button2Trailing.isActive = false
        button2Bottom.isActive = false
        showButton2Trailing = button2.trailingAnchor.constraint(equalTo: button3.leadingAnchor, constant: -7.5)
        showButton2Trailing.isActive = true
        showButton2Bottom = button2.bottomAnchor.constraint(equalTo: button1.topAnchor, constant: -7.5)
        showButton2Bottom.isActive = true
        
        // Animate menu button rotation then bring out buttons
        UIView.animate(withDuration: 0.35, delay: 0.0, animations: {
            // Rotate Menu Button 90 degress
            self.menuButton.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi / 2))
            // Show Buttons
            self.button1.alpha = 1.0
            self.button2.alpha = 1.0
            self.button3.alpha = 1.0
            self.layoutIfNeeded()
        }, completion: { _ in
            // Switch Menu Button function
            self.menuButton.removeTarget(self, action: #selector(self.add3buttons), for: .touchUpInside)
            self.menuButton.addTarget(self, action: #selector(self.rotateButton90), for: .touchUpInside)
        })
    }
    
    @objc func rotateButton90() {
        // Remove Buttons and rotate menu button
        // Hide Button 1
        showButton1Trailing.isActive = false
        button1Trailing.isActive = true
        // Hide Button 3
        showButton3Bottom.isActive = false
        button3Bottom.isActive = true
        // Hide Button 2
        showButton2Trailing.isActive = false
        showButton2Bottom.isActive = false
        button2Trailing.isActive = true
        button2Bottom.isActive = true
        
        UIView.animate(withDuration: 0.35, animations: {
            // Rotate Menu Button back
            self.menuButton.transform = .identity
            // Hide Buttons
            self.button1.alpha = 0.0
            self.button2.alpha = 0.0
            self.button3.alpha = 0.0
            self.layoutIfNeeded()
        }, completion: { _ in
            // Remove Buttons from superview
            self.removeMenuButtons(all: false)
            // Switch Menu Button function
            self.menuButton.removeTarget(self, action: #selector(self.rotateButton90), for: .touchUpInside)
            self.menuButton.addTarget(self, action: #selector(self.add3buttons), for: .touchUpInside)
        })
    }
    
    // Button 1 - Route functions
    
    @objc func showRoute2() {
        // Check if Station list is active - if so remove station lists
        if showingAllStations {
            print("Removing all stations first")
            var annotationsToRemove = [MKAnnotation]()
            for annotation in self.map.annotations {
                if annotation.title == closestStation.name {
                    continue
                }
                if annotation.isKind(of: MKUserLocation.self) {
                    continue
                }
                annotationsToRemove.append(annotation)
            }
            UIView.animate(withDuration: 1.0, animations: {
                for annotation in annotationsToRemove {
                    self.map.view(for: annotation)?.alpha = 0.0
                }
            }, completion: { _ in
                self.map.removeAnnotations(annotationsToRemove)
                self.showingAllStations = false
                self.showRouteHelper()
            })

        } else {
            print("Not Displaying All Stations")
            showRouteHelper()
        }
    }
    
    // Button 2 - Station list functions
    
    
//    @objc func showRoute() {
//        // if all stations are shown, remove all BUT closest Station then show route
//        if self.map.annotations.count > 2 {
//            removeMostStations(completion: { complete in
//                if complete {
//                    self.showRouteHelper()
//                }
//            })
//        } else {
//            showRouteHelper()
//        }
//
//    }
    
    func showRouteHelper() {
        // Take current station location on map
        print("Showing Route...")
        // Take Closest Station and user locatin - find route between them
        // set up route
        let sourceLocation = MKMapItem.forCurrentLocation()
        let destinationLocation = MKMapItem(placemark: MKPlacemark(coordinate: (CLLocationCoordinate2D(latitude: closestStation.location.coordinate.latitude, longitude: closestStation.location.coordinate.longitude))))
        
        // Route request
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceLocation
        directionRequest.destination = destinationLocation
        directionRequest.transportType = .automobile
        
        // Calculate route path
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {(response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error with route overlay: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            var zoomRect = MKMapRect.null
            print("ALL ANNOTATIONS IN CLOSEST STATION")
            for annotation in self.map.annotations {
                let annoPoint = MKMapPoint(annotation.coordinate)
                let rect = MKMapRect(x: annoPoint.x, y: annoPoint.y, width: 1.0, height: 1.0)
                
                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            zoomRect = zoomRect.union(rect)
            let padding = UIEdgeInsets(top: 66.0, left: 44.0, bottom: 44.0, right: 66.0)
            let biggerRect = self.map.mapRectThatFits(zoomRect, edgePadding: padding)
            self.map.setRegion(MKCoordinateRegion(biggerRect), animated: true)
            self.showingRoute = true
        })
        
        // Change button function to remove route overlay and resize view
        self.button1.removeTarget(self, action: #selector(showRoute2), for: .touchUpInside)
        self.button1.addTarget(self, action: #selector(removeRoute), for: .touchUpInside)
    }
    
    @objc func removeRoute() {
        // Remove Route
        self.map.removeOverlays(self.map.overlays)
        // Resize padding
        showingRoute = false
        fitVisualMap()
        
        // Change Button Function
        self.button1.removeTarget(self, action: #selector(removeRoute), for: .touchUpInside)
        self.button1.addTarget(self, action: #selector(showRoute2), for: .touchUpInside)
    }
    
    @objc func showAllStations() {
        // show All stations from user Defaults
        let stationListUD = UserDefaults.standard.value(forKey: "StationList") as! Data
        let stationList = try? PropertyListDecoder().decode(Array<Station>.self, from: stationListUD)
        
        
        if var stationList = stationList {
            // Remove closestStation
            stationList.removeAll { $0.name == closestStation.name }
            // Go through station list, add pin to map, if coordinate already matches closest station, ignore
            var zoomRect = MKMapRect.null
            
            let annotations = stationList.map { station -> MKAnnotation in
                // Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = station.name
                annotation.coordinate = station.location.coordinate
                
                //Get rect for zooming purposes
                let stationPoint = MKMapPoint(annotation.coordinate)
                let rect = MKMapRect(x: stationPoint.x, y: stationPoint.y, width: 1.0, height: 1.0)

                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
                
                return annotation
            }
            self.map.addAnnotations(annotations)
            
            self.map.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 66, left: 44, bottom: 44, right: 66 ), animated: true)
            // Change flag
            self.showingAllStations = true
            // Change button Function to remove all but ClosestStation if avaliable
            self.button2.removeTarget(self, action: #selector(showAllStations), for: .touchUpInside)
            self.button2.addTarget(self, action: #selector(button2RemoveMostStations), for: .touchUpInside)
        } else {
            print("Unable to decode user default: StationList")
            return
        }
    }
    
    func removeMostStations(completion: @escaping (_ completed: Bool) -> ()) {
        // Station list must be showing
        // Create Temporary Array of annotation
        var annotationsToRemove = [MKAnnotation]()
        for annotation in self.map.annotations {
            if annotation.title == closestStation.name {
                continue
            }
            if annotation.isKind(of: MKUserLocation.self) {
                continue
            }
            annotationsToRemove.append(annotation)
        }
        UIView.animate(withDuration: 1.0, animations: {
            for annotation in annotationsToRemove {
                self.map.view(for: annotation)?.alpha = 0.0
            }
        }, completion: { _ in
            self.map.removeAnnotations(annotationsToRemove)
            self.showingAllStations = false
            completion(true)
        })
    }
    
    @objc func button2RemoveMostStations() {
        removeMostStations(completion: { complete in
            if complete {
                self.fitVisualMap()
                self.button2.removeTarget(self, action: #selector(self.button2RemoveMostStations), for: .touchUpInside)
                self.button2.addTarget(self, action: #selector(self.showAllStations), for: .touchUpInside)
            }
        })
    }
    
    // Button 3 - Open Google maps
    @objc func openGoogleMaps() {
        if let nearestStation = closestStation {
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(nearestStation.latitude),\(nearestStation.longitude)&directionsmode=driving")! as URL)
            } else {
                NSLog("Can't use comgooglemaps://");
            }
        }
    }
    
    
    func removeMenuButtons(all: Bool) {
        button3.removeFromSuperview()
        button2.removeFromSuperview()
        button1.removeFromSuperview()
        if all {
            menuButton.removeFromSuperview()
            
            if showingRoute && showingAllStations {
                print("Removing both")
                removeMostStations(completion: { complete in
                    if complete {
                        self.removeRoute()
                        return
                    }
                })
            }
            
            if showingRoute {
                print("Removing Route")
                removeRoute()
            }
            
            if showingAllStations {
                print("Removing Most Stations")
                removeMostStations(completion: { complete in
                    if complete {
                        return
                    }
                })
            }
            
        }
    }
}
