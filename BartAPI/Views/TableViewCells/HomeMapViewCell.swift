//
//  HomeMapCell.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/25/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class HomeMapViewCell: UITableViewCell, MKMapViewDelegate {
    
    @IBOutlet var homeMapView: MKMapView! {
        didSet {
            homeMapView.delegate = self
            // SET DEFAULT MAP TO BAY AREA
            self.homeMapView.setVisibleMapRect(MKMapRect(x: 42898162.432955734, y: 103525349.38215713, width: 513503.85990115255, height: 487384.8018284887), edgePadding: UIEdgeInsets(top: 35, left: 0, bottom: 30, right: 0 ), animated: true)

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // SHOWS ALL STATIONS ON MAP - Restricted Mode on
    func setUpRestricted(listOfStations: [Station]) {
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
        self.homeMapView.addAnnotations(annotations)
        self.homeMapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 35, left: 0, bottom: 30, right: 0 ), animated: true)
    }
    
    // SHOWS NEAREST STATION ON MAP WITH CURRENT LOCATION - Normal Mode on
    func setUpNearest(nearestStation: Station){
//        self.homeMapView.removeAnnotations(self.homeMapView.annotations)
        if !homeMapView.annotations.isEmpty {
            UIView.animate(withDuration: 1.5, animations: {
                for annotation in self.homeMapView.annotations {
                    if annotation.title != nearestStation.name {
                        self.homeMapView.view(for: annotation)?.alpha = 0.0
                    }
                }
            }, completion: { _ in
                self.homeMapView.removeAnnotations(self.homeMapView.annotations)
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

        self.homeMapView.addAnnotation(annotation)
    
        // Get user location and set up
        guard let _ = CLLocationManager().location else { return }
        CLLocationManager().startUpdatingLocation()
        self.homeMapView.showsUserLocation = true
        
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
            self.homeMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            var zoomRect = MKMapRect.null
            
            for annotation in self.homeMapView.annotations {
                let annoPoint = MKMapPoint(annotation.coordinate)
                let rect = MKMapRect(x: annoPoint.x, y: annoPoint.y, width: 1.0, height: 1.0)
                
                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            zoomRect = zoomRect.union(rect)
            let padding = UIEdgeInsets(top: 35.0, left: 25.0, bottom: 20.0, right: 35.0)
            let biggerRect = self.homeMapView.mapRectThatFits(zoomRect, edgePadding: padding)
            self.homeMapView.setRegion(MKCoordinateRegion(biggerRect), animated: true)
        })
    }
    
        
    // CUSTOMIZE ANNOTATION ICON
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
        annotationView?.isEnabled = false
        annotationView?.displayPriority = .required
        annotationView?.alpha = 1.0

        return annotationView
        
    }
    
    // DRAW ROUTE TO NEAREST STATION
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.Custom.annotationBlue
        renderer.lineWidth = 4.0
        
        return renderer
    }



}
