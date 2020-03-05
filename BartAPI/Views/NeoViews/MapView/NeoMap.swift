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
    
    var showUserLocation: Bool = true
    
    lazy var topLeftShadow = CALayer()
    lazy var bottomRightShadow = CALayer()
    
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
    func setUpNearest(nearestStation: Station){
        if !self.map.annotations.isEmpty {
            print("Map annotations are not empty")
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
        
        // set up route
        let sourceLocation = MKMapItem.forCurrentLocation()
        let destinationLocation = MKMapItem(placemark: MKPlacemark(coordinate: (CLLocationCoordinate2D(latitude: nearestStation.location.coordinate.latitude, longitude: nearestStation.location.coordinate.longitude))))
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceLocation
        directionRequest.destination = destinationLocation
        directionRequest.transportType = .automobile
        
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
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topLeftShadow.frame = bounds
        layer.insertSublayer(topLeftShadow, at: 0)
        
        bottomRightShadow.frame = bounds
        layer.insertSublayer(bottomRightShadow, at: 0)
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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
