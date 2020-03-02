//
//  NeoHomeViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/2/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class NeoHomeViewController: UIViewController {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var circularMap: NeoMap!
    var locationManager: CLLocationManager = CLLocationManager()
    
    var nearestStationTableView: NeoTableView!
    var nextTrainLabel: UILabel!
    var nextTrainsTableView: NeoTableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
