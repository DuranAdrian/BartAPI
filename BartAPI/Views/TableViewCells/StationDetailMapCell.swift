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
            mapView.delegate = self
        }
    }

    fileprivate let locationManager: CLLocationManager! = CLLocationManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setUpLocationManager()
    }
    
    func setUpLocationManager(_ closestStation: Station?) {
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
            
            mapView.setRegion(region, animated: true)
            mapView.userTrackingMode = .follow

            // FOR ROUTE SET UP
            setUpRoute(validStation.location)
        } else {
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    func setUpRoute(_ destination: CLLocation) {
        let sourceLocation = MKMapItem.forCurrentLocation()
        let destinationLocation = MKMapItem(placemark: MKPlacemark(coordinate: (CLLocationCoordinate2D(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude))))
        
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
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        })
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.Custom.annotationBlue
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func locationToMap(location: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
        
            if let error = error {
                print("Error reversing GeoCodeLocaiton: \(error)")
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
        geoCoder.geocodeAddressString(location, completionHandler: { placemarks, error in
            if let error = error {
                print("Error with geocodeAddressString: \(error.localizedDescription)")
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

