//
//  NeoFareViewController.swift
//  BartAPI
//
//  Created by Adrian Duran on 3/10/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class NeoFareViewController: UIViewController {
    
    var stationsLabel: UILabel!
    var segController: NeoSegController!
    var pickerWheel: UIPickerView!
    var stationList: [Station]!
    var viewFareButton: NeoButton!
    
    lazy var fromStation: String = ""
    lazy var toStation: String = ""
    lazy var tripFare: FareContainer? = nil
    
    var fareTableView = UITableView()
    // WILL DETERMINE IF FARE TABLEVIEW IS VISIBLE
    lazy var fareSubViewFlag: Bool = false
    
    var activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        let stationListUD = UserDefaults.standard.value(forKey: "StationList") as! Data
        stationList = try? PropertyListDecoder().decode(Array<Station>.self, from: stationListUD)
        view.backgroundColor = UIColor.Custom.smokeWhite
        setUpNavBar()
        setUpComponents()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setUpComponents() {
        // set up station label on top
        stationsLabel = UILabel()
        stationsLabel.text = "Select 2 Stations"
        stationsLabel.textAlignment = .center
        stationsLabel.setContentHuggingPriority(.init(251), for: .horizontal)
        stationsLabel.setContentHuggingPriority(.init(251), for: .vertical)
        stationsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stationsLabel)
        
        // setup seg controller underneth
        segController = NeoSegController(items: ["From","To"])
        segController.center = view.center
        segController.selectedSegmentIndex = 0
        segController.setContentHuggingPriority(.init(251), for: .vertical)
        segController.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segController)
        
        // setup pickerwheel in middle
        
        pickerWheel = UIPickerView()
        pickerWheel.delegate = self
        pickerWheel.dataSource = self
        pickerWheel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerWheel)
        
        // setup fare button at bottom
        viewFareButton = NeoButton()
        viewFareButton.setTitle("View Fare", for: .normal)
        viewFareButton.addTarget(self, action: #selector(calculateFare), for: .touchUpInside)
        viewFareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewFareButton)
        
        NSLayoutConstraint.activate([
            //Stations Label
            stationsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stationsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            stationsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            stationsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            // Seg Controller
            segController.topAnchor.constraint(equalTo: stationsLabel.bottomAnchor, constant: 10),
            segController.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 75),
            segController.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -75),
            
            // Picker Wheel
            pickerWheel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pickerWheel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pickerWheel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerWheel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // View Fare Button
            viewFareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            viewFareButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            viewFareButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            viewFareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    fileprivate func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Fare"
        let activityIcon = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(activityIcon, animated: true)
    }
    
    fileprivate func setUpTableView() {
        fareTableView.dataSource = self
        fareTableView.delegate = self
        fareTableView.tableFooterView = UIView()
        fareTableView.separatorColor = .clear
        fareTableView.allowsSelection = false
        fareTableView.allowsMultipleSelection = false
        if #available(iOS 13, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                fareTableView.backgroundColor = .darkGray
            } else {
                fareTableView.backgroundColor = .systemGray6
            }
        } else {
            fareTableView.backgroundColor = .lightGray
        }
        fareTableView.layer.cornerRadius = 15.0
        fareTableView.layer.masksToBounds = true
        fareTableView.layer.borderWidth = 1
        fareTableView.layer.borderColor = UIColor.Custom.annotationBlue.cgColor

        // REMOVE ALL DEFAULT GESTURES.
        fareTableView.gestureRecognizers?.removeAll()
        // ADD TAP GESTURE TO REMOVE VIEW
        let tapRemove = UITapGestureRecognizer(target: self, action: #selector(removeFareTableView(_:)))
        tapRemove.numberOfTouchesRequired = 1
        tapRemove.numberOfTapsRequired = 1
        fareTableView.addGestureRecognizer(tapRemove)
        
        // ADD SWIPE DOWN GESTURE TO REMOVE VIEW
        let swipeDownRemove = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRemoveFareTableView(_:)))
        swipeDownRemove.direction = .down
        fareTableView.addGestureRecognizer(swipeDownRemove)
        
        fareTableView.register(FareCostCell.self, forCellReuseIdentifier: "FareCostCell")
    }
    
    @objc func calculateFare() {
        viewFareButton.showLoading()
        
        // Ensure station abbrevitations are correct
        guard let station1 = stationList.firstIndex(where: {$0.name == fromStation}) else { viewFareButton.hideLoading()
            return
        }
        guard let station2 = stationList.firstIndex(where: {$0.name == toStation}) else { viewFareButton.hideLoading()
            return
        }
        // Pull Data
        DispatchQueue.global(qos: .userInitiated).async {
            NetworkManager().schedules.getFare(from: self.stationList[station1].abbreviation, to: self.stationList[station2].abbreviation, completion: { fare, error in
                if let error = error {
                    print("Error finding fare: \(error)")
                    DispatchQueue.main.async {
                        self.viewFareButton.hideLoading()
                        return
                    }
                }
                if let fare = fare {
                    self.tripFare = fare
                    DispatchQueue.main.async {
                        self.fareTableView.reloadData()
                        self.createFarePopUp()
                        self.viewFareButton.hideLoading()
                        print(self.tripFare)
                    }
                }
            })
        }
    }
    
    fileprivate func createFarePopUp() {
        // ADD FARETABLEVIEW TO BOTTOM OF VIEW
        fareTableView.layoutIfNeeded()
        fareTableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: fareTableView.contentSize.height + self.tabBarController!.tabBar.frame.height)
        
        self.view.addSubview(fareTableView)
        
        UIView.animate(withDuration: 1.0, animations: {
            self.fareTableView.frame.origin.y = self.view.frame.height - (self.fareTableView.contentSize.height + self.tabBarController!.tabBar.frame.height)
        })
    }
    
    @objc func removeFareTableView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1.0, animations: {
            self.fareTableView.frame.origin.y = self.view.frame.height
        }, completion: { _ in
            self.fareTableView.removeFromSuperview()
            self.fareSubViewFlag = false
        })
    }
    
    @objc func swipeToRemoveFareTableView(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 1.0, animations: {
            self.fareTableView.frame.origin.y = self.view.frame.height
        }, completion: { _ in
            self.fareTableView.removeFromSuperview()
            self.fareSubViewFlag = false
        })
    }

}

extension NeoFareViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

class HalfSizePresentationController : UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height/2, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
}


extension NeoFareViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stationList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if segController.selectedSegmentIndex == 0 {
            // FROM SELECTION
            fromStation = stationList[row].name
        } else {
            // TO SELECTION
            toStation = stationList[row].name
        }
        stationsLabel.text = fromStation + " to " + toStation
        stationsLabel.adjustsFontSizeToFitWidth = true
        if (!toStation.isEmpty && !fromStation.isEmpty) && (fromStation != toStation) {
            viewFareButton.isEnabled = true
//            viewFareButton.layer.backgroundColor = UIColor.Custom.annotationBlue.cgColor
        }
        if fromStation == toStation {
            viewFareButton.isEnabled = false
//            viewFareButton.layer.backgroundColor = UIColor.darkGray.cgColor
        }

    }
}

extension NeoFareViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripFare?.standardFares.fare.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FareCostCell.self), for: indexPath) as! FareCostCell
        print("Using the following trip fare: \(tripFare!.standardFares.fare)")
        let fare = tripFare!.standardFares.fare[indexPath.row]
        cell.cost.text = "$ \(fare.amount)"
        
        if fare.type == "Rtcclipper" {
            cell.fareType.text = fare.name
        } else {
            cell.fareType.text = fare.type
        }
        
        
        if #available(iOS 13, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                cell.layer.backgroundColor = UIColor.darkGray.cgColor
            } else {
                cell.layer.backgroundColor = UIColor.systemGray6.cgColor
            }
        } else {
            cell.layer.backgroundColor = UIColor.systemGray6.cgColor
        }

        return cell
 
    }

}
