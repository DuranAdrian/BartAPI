//
//  StationListViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/9/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NeoStationListViewController: UIViewController {
    
    // Station TableView
    var stationsTableView: NeoTableView!
    private var stationList: [Station]? = nil
    
    // Search Bar
    var searchController = UISearchController()
    var searchResults = [Station]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Custom.smokeWhite
        let stationListUD = UserDefaults.standard.value(forKey: "StationList") as! Data
        stationList = try? PropertyListDecoder().decode(Array<Station>.self, from: stationListUD)
        setUpNavBar()
        setUpSearchBar()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    private func setUpSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController

    }
    
    private func setUpNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.Custom.smokeWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Station List"
    }
    
    private func setUpTableView() {
        stationsTableView = NeoTableView()
        stationsTableView.tableView.delegate = self
        stationsTableView.tableView.dataSource = self
        stationsTableView.tableView.alwaysBounceVertical = false
        stationsTableView.tableView.register(StationListCell.self, forCellReuseIdentifier: "StationListCell")
        stationsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stationsTableView)
        
        NSLayoutConstraint.activate([
            stationsTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            stationsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stationsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            stationsTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -15)
        ])
    }
    
}

extension NeoStationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let stationList = stationList {
            if searchController.isActive {
                return searchResults.count
            } else {
                return stationList.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let stationList = stationList {
            // Get station
//            let station = stationList[indexPath.row]
            let station = (searchController.isActive) ? searchResults[indexPath.row] : stationList[indexPath.row]
            // DequeStationCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "StationListCell", for: indexPath) as! StationListCell
            cell.stationAbbr.text = station.abbreviation
            cell.stationCity.text = station.city
            cell.stationName.text = station.name
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "StationDetails", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NeoStationDetailViewController") as! NeoStationDetailViewController
        if let stationList = stationList {
            vc.station = searchController.isActive ? searchResults[indexPath.row] : stationList[indexPath.row]
            vc.navigationItem.title = vc.station.name
            navigationController?.pushViewController(vc, animated: true)
        }

    }
}

extension NeoStationListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            stationsTableView.tableView.reloadData()
        }
    }
    
    private func filterContent(for searchText: String) {
        if let stationList = stationList {
            searchResults = stationList.filter({ (station) -> Bool in
                let isMatch = station.name.localizedCaseInsensitiveContains(searchText)
                return isMatch
            })

        }
    }
}

