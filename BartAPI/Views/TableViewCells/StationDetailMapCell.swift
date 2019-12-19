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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
                    self.mapView.addAnnotation(annotation)
                    
                    // Set Zoom Level
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 450, longitudinalMeters: 450)
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
