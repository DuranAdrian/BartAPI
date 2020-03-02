//
//  NeoHomeViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/2/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit
import MapKit

class NeoHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
        view.backgroundColor = UIColor.Custom.smokeWhite
        setUpTabBar()
        setUpNavBar()
        setUpScrollView()
        setUpComponents()
    }
    
    private func setUpTabBar() {
        tabBarController?.tabBar.barTintColor = UIColor.Custom.smokeWhite
    }
    
    private func setUpNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.Custom.smokeWhite
        navigationItem.title = "HOME"
    }
    
    private func setUpScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setUpComponents() {
        // Add CircularMap
        circularMap = NeoMap(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        circularMap.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(circularMap)
        
        // Add Nearest Station
        nearestStationTableView = NeoTableView()
        nearestStationTableView.tableView.delegate = self
        nearestStationTableView.tableView.dataSource = self
        nearestStationTableView.isUserInteractionEnabled = false
        nearestStationTableView.tableView.register(NearestStationCell.self, forCellReuseIdentifier: "NearestStationCell")
        nearestStationTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nearestStationTableView)
        
        // NextTrainLabel
        nextTrainLabel = UILabel()
        nextTrainLabel.text = "Next Arriving Train"
        nextTrainLabel.numberOfLines = 1
        nextTrainLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        nextTrainLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nextTrainLabel)
        
        // Add NextTrains
        nextTrainsTableView = NeoTableView()
        nextTrainsTableView.tableView.delegate = self
        nextTrainsTableView.tableView.dataSource = self
        nextTrainsTableView.isUserInteractionEnabled = false
        nextTrainsTableView.tableView.register(NextTrainCell.self, forCellReuseIdentifier: "NextTrainCell")
        nextTrainsTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(nextTrainsTableView)

        
        NSLayoutConstraint.activate([
            // CircularMap
            circularMap.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            circularMap.centerXAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.centerXAnchor),
            circularMap.widthAnchor.constraint(equalToConstant: 300),
            circularMap.heightAnchor.constraint(equalToConstant: 300),
            
            // Nearest Station
            nearestStationTableView.topAnchor.constraint(equalTo: circularMap.bottomAnchor, constant: 50),
            nearestStationTableView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            nearestStationTableView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            // Next Train Label
            nextTrainLabel.topAnchor.constraint(equalTo: nearestStationTableView.bottomAnchor, constant: 20),
            nextTrainLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            // Next Trains
            nextTrainsTableView.topAnchor.constraint(equalTo: nextTrainLabel.bottomAnchor, constant: 10),
            nextTrainsTableView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            nextTrainsTableView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextTrainsTableView.bottomAnchor, constant: 10)
        ])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
