//
//  StationDetailMapCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 12/17/19.
//  Copyright © 2019 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class StationDetailMapCell: UITableViewCell, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            print("Setting mapView")
            mapView.delegate = self
            print("Showing userLocation: \(mapView.showsUserLocation)")
        }
    }
    
    fileprivate let locationManager: CLLocationManager! = CLLocationManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakeFromNib")
//        setUpLocationManager()
    }
    
    func setUpLocationManager(_ closestStation: Station?) {
//        print("Setting up location manager")
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        guard let userLocation = locationManager?.location else { return }
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        if let validStation = closestStation {
            
            self.locationToMap(location: validStation.location)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = userLocation.coordinate
//            mapView.addAnnotation(annotation)
            
//            print(Thread.current)
//            sleep(10000)
            mapView.setRegion(region, animated: true)
            mapView.userTrackingMode = .follow
            print("Number of annotations: \(self.mapView.annotations.count)")
            for annotation in self.mapView.annotations {
                print("Name: \(annotation.title)")
            }
        } else {
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    func testingClosure(firstBlock: (() -> Void)? = nil, secondBlock: (() -> Void)? = nil) {
        
        print("Inside function: \(Thread.current)")
        let group = DispatchGroup()

        group.enter()
        print("Starting first block")
        firstBlock?()
        print("First block is now done")
        group.leave()
        group.notify(queue: .main) {secondBlock?()}
            
        
//        print("Starting second block")
//
////        secondBlock?()
//        print("Second block is now done")
//        group.leave()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    func locationToMap(location: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
        
            if let error = error {
                print(error)
            }
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                // Add Annotation
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    // Display Annotation
                    annotation.coordinate = location.coordinate
                    annotation.title = "Station"
                    self.mapView.addAnnotation(annotation)
                    print("New number of annotions: \(self.mapView.annotations.count)")
//                    for annotation in self.mapView.annotations {
//                        print("New name: \(annotation.title)")
//                    }
                    // Set Zoom Level
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 450, longitudinalMeters: 450)
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    self.mapView.setRegion(region, animated: false)
                }
            }
            
        })
    }

    func addressToMap(location: String) {
        // Get Location
        let geoCoder = CLGeocoder()
        print(location)
        geoCoder.geocodeAddressString(location, completionHandler: { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // Get First PlaceMark
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                // Add Annotation
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    // Display Annotation
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    // Set Zoom Level
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 450, longitudinalMeters: 450)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }
    
}

