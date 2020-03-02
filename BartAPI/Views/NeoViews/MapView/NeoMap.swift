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
        // Maybe redudent, but double check if locations are enabled
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

//        annotationView?.glyphText = "😋"
        annotationView?.glyphImage = UIImage(systemName: "tram.fill")
        annotationView?.markerTintColor = UIColor.Custom.smokeWhite

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
