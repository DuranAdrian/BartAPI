//
//  MapKit+Ext.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/15/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    func addLocation(_ location: CLLocation) {
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
                    self.addAnnotation(annotation)
                    
                    // Set Zoom Level
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 450, longitudinalMeters: 450)
                    self.showAnnotations(self.annotations, animated: true)
                    self.setRegion(region, animated: false)
                }
            }
        })
    }
    
    
    func routeToDestination(_ destination: CLLocation) {
        self.showsUserLocation = true
        self.addLocation(destination)
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
            self.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            // Rect of route
            let rect = route.polyline.boundingMapRect
            let padding = UIEdgeInsets(top: 35.0, left: 35.0, bottom: 35.0, right: 35.0)
            let biggerRect = self.mapRectThatFits(rect, edgePadding: padding)
            
            self.setRegion(MKCoordinateRegion(biggerRect), animated: true)
            
        })
    }
    
    func removeRoute() {
        self.removeOverlays(self.overlays)
    }

}
