//
//  FarePickerController.swift
//  BartAPI
//
//  Created by Adrian Duran on 1/17/20.
//  Copyright © 2020 Adrian Duran. All rights reserved.
//

import UIKit

class FarePickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var stationsLabel: UILabel! {
        didSet {
            stationsLabel.text = "Select 2 Stations"
        }
    }
    @IBOutlet weak var segController: FareSegController! {
        didSet {
            segController.addTarget(self, action: #selector(selectPicker(_:)), for: .valueChanged)
        }
    }
    @IBOutlet weak var pickerWheel: UIPickerView!
    @IBOutlet weak var viewFareButton: loadingButton! {
        didSet {
            viewFareButton.isEnabled = false
            viewFareButton.layer.backgroundColor = UIColor.darkGray.cgColor
            viewFareButton.addTarget(self, action: #selector(calculateFare(_:)), for: .touchUpInside)
        }
    }
    
    lazy var fromStation: String = ""
    lazy var toStation: String = ""
    lazy var tripFare: FareContainer? = nil
    var fareTableView = UITableView()
    // WILL DETERMINE IF FARE TABLEVIEW IS VISIBLE
    lazy var fareSubViewFlag: Bool = false
    
    var activityIndicator: UIActivityIndicatorView!

    
    // FIXME: - Replace with [Station]
    // Picker Data
    // In order to show Stations name , Needed to create an array of sorted keys every single time. might as well create a single one to be used when needed.
    var pickerDataKeys: [String] = ["12th St. Oakland City Center", "16th St. Mission", "19th St. Oakland", "24th St. Mission", "Antioch", "Ashby", "Balboa Park", "Bay Fair", "Castro Valley", "Civic Center/UN Plaza", "Coliseum", "Colma", "Concord", "Daly City", "Downtown Berkeley", "Dublin/Pleasanton", "El Cerrito del Norte", "El Cerrito Plaza", "Embarcadero", "Fremont", "Fruitvale", "Glen Park", "Hayward", "Lafayette", "Lake Merritt", "MacArthur", "Millbrae", "Montgomery St.", "North Berkeley", "North Concord/Martinez", "Oakland International Airport", "Orinda", "Pittsburg/Bay Point", "Pittsburg Center", "Pleasant Hill/Contra Costa Centre", "Powell St.", "Richmond", "Rockridge", "San Bruno", "San Francisco International Airport", "San Leandro", "South Hayward", "South San Francisco", "Union City", "Walnut Creek", "Warm Springs/South Fremont", "West Dublin/Pleasanton", "West Oakland"]
    var pickerDataDictionary: [String:String] = ["12th St. Oakland City Center": "12th", "16th St. Mission": "16th", "19th St. Oakland": "19th", "24th St. Mission": "24th", "Antioch": "antc", "Ashby": "ashb", "Balboa Park": "balb", "Bay Fair": "bayf", "Castro Valley": "cast", "Civic Center/UN Plaza": "civc", "Coliseum": "cols", "Colma": "colm", "Concord": "conc", "Daly City": "daly", "Downtown Berkeley": "dbrk", "Dublin/Pleasanton": "dubl", "El Cerrito del Norte": "deln", "El Cerrito Plaza": "plza", "Embarcadero": "embr", "Fremont": "frmt", "Fruitvale": "ftvl", "Glen Park": "glen", "Hayward": "hayw", "Lafayette": "lafy", "Lake Merritt": "lake", "MacArthur": "mcar", "Millbrae": "mlbr", "Montgomery St.": "mont", "North Berkeley": "nbrk", "North Concord/Martinez": "ncon", "Oakland International Airport": "oakl", "Orinda": "orin", "Pittsburg/Bay Point": "pitt", "Pittsburg Center": "pctr", "Pleasant Hill/Contra Costa Centre": "phil", "Powell St.": "powl", "Richmond": "rich", "Rockridge": "rock", "San Bruno": "sbrn", "San Francisco International Airport": "sfia", "San Leandro": "sanl", "South Hayward": "shay", "South San Francisco": "ssan", "Union City": "ucty", "Walnut Creek": "wcrk", "Warm Springs/South Fremont": "warm", "West Dublin/Pleasanton": "wdub", "West Oakland": "woak"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        self.pickerWheel.delegate = self
        self.pickerWheel.dataSource = self
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // RESET VIEW top to bottom
        fromStation = ""
        toStation = ""
        stationsLabel.text = "Select 2 Stations"
        
        segController.selectedSegmentIndex = 0

        pickerWheel.selectRow(0, inComponent: 0, animated: false)
        
        viewFareButton.isEnabled = false
        viewFareButton.layer.backgroundColor = UIColor.darkGray.cgColor
        viewFareButton.setTitle("View Fare", for: .normal)
        if fareSubViewFlag {
            // Remove fare subviews. no animation
            fareTableView.removeFromSuperview()
            fareSubViewFlag = false
        }
        
    }
    
    func pullFareData(completionHandler: @escaping (FareContainer) -> Void) {
        let fareAPIURL = "https://api.bart.gov/api/sched.aspx?cmd=fare&orig=\(pickerDataDictionary[fromStation]!)&dest=\(pickerDataDictionary[toStation]!)&key=MW9S-E7SL-26DU-VV8V&json=y"
        guard let fareURL = URL(string: fareAPIURL) else { print("Unable to create fareURL");return }
        
        let task = URLSession.shared.dataTask(with: fareURL, completionHandler: { (data, response, error ) -> Void in
            if let error = error {
                print("Unable to connect to API \(error)")
                return
            }
            
            if let data = data {
                
                let parsedData = self.parseFareJSONData(data: data)
                print("Completed pulling data...")
                completionHandler(parsedData)
            }
        })
        task.resume()
    }
    
    func parseFareJSONData(data: Data) -> FareContainer {
        let decoder = JSONDecoder()
        let container = [FareContainer]()
        do {
            let fareData = try decoder.decode(FareContainer.self, from: data)
            print("Completed parsing...")
            return fareData
            
        } catch {
            print("Error parsing FARE JSON data: \(error)")
            return container[0]
        }
    }
    
    func setUpTableView() {
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
        
        fareTableView.register(UINib(nibName: "FareCostCell", bundle: nil), forCellReuseIdentifier: "FareCostCell")
    }
    
    func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Fare"
        self.changeNavBarColors_Ext()
    }
    
    func createFarePopUp() {
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
    
    @objc func selectPicker(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                print("Selected index 0")
                if !fromStation.isEmpty {
                    pickerWheel.selectRow(pickerDataKeys.firstIndex(of: fromStation)!, inComponent: 0, animated: true)
                } else {
                    pickerWheel.selectRow(0, inComponent: 0, animated: true)
                }
                break
            case 1:
                print("Selected index 1")
                if !toStation.isEmpty {
                    pickerWheel.selectRow(pickerDataKeys.firstIndex(of: toStation)!, inComponent: 0, animated: true)
                } else {
                    pickerWheel.selectRow(0, inComponent: 0, animated: true)
                }
                break
            default:
                break
        }
    }
    
    @objc func calculateFare(_ sender: UIButton) {
        self.viewFareButton.setTitle("Loading...", for: .normal)
        self.viewFareButton.showLoading()
        pullFareData(completionHandler: { [weak self ] (tripFare) in
            self?.tripFare = tripFare
            DispatchQueue.main.async {
                self?.createFarePopUp()
                self?.viewFareButton.hideLoading()
                self?.viewFareButton.setTitle("View Fare", for: .normal)
            }
        })
    }
    

    // MARK: - PickerView

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataKeys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected: \(pickerDataKeys[row])")
        if segController.selectedSegmentIndex == 0 {
            // FROM SELECTION
            fromStation = pickerDataKeys[row]
        } else {
            // TO SELECTION
            toStation = pickerDataKeys[row]
        }
        stationsLabel.text = fromStation + " to " + toStation
        stationsLabel.adjustsFontSizeToFitWidth = true
        if (!toStation.isEmpty && !fromStation.isEmpty) && (fromStation != toStation) {
            viewFareButton.isEnabled = true
            viewFareButton.layer.backgroundColor = UIColor.Custom.annotationBlue.cgColor
        }
        if fromStation == toStation {
            viewFareButton.isEnabled = false
            viewFareButton.layer.backgroundColor = UIColor.darkGray.cgColor

        }
    }

}

extension FarePickerController: UIViewControllerTransitioningDelegate {
    
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

extension FarePickerController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripFare?.standardFares.fare.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FareCostCell.self), for: indexPath) as! FareCostCell
        
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

extension FarePickerController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.changeNavBarColors_Ext()
        self.changeTabBarColors_Ext()
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            if previousTraitCollection?.userInterfaceStyle == .dark {
                // GONE TO LIGHT
                fareTableView.backgroundColor = .systemGray6
            } else {
                // GONE TO DARK
                fareTableView.backgroundColor = .darkGray
            }
            
            fareTableView.reloadSections(IndexSet(integer: 0), with: .fade)
            fareTableView.layoutIfNeeded()

        }
    }
}



