//
//  SearchViewController.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/1/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    var foodSearchResults = [[String:AnyObject]]()
    var foodNames = [String]()
    var ndbnoList = [String]()
    var mealType = String?()
    var foodIndex = Int?()
    var date: String?
    var dataSource:String?
    var reach: Reachability?
    var mealsViewController: MealsViewController_1? = MealsViewController_1()

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var standardButton: RadioButton!
    @IBOutlet weak var brandedButton: RadioButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        searchResultsTableView.estimatedRowHeight = 68.0
        searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        searchTextField.delegate = self
        standardButton.isChecked = true
        dataSource = "Standard Reference"
        activityView.alpha = 0.0
        activityIndicator.layer.cornerRadius = 10
        
        self.reach = Reachability.reachabilityForInternetConnection()
        checkInternetConnection()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(SearchViewController.reachabilityChanged(_:)),
                                                         name: kReachabilityChangedNotification,
                                                         object: nil)
        
        self.reach!.startNotifier()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        searchResultsTableView.allowsSelection = true
        activityView.alpha = 0.0
        activityIndicator.stopAnimating()
    }
    
    func reachabilityChanged(notification: NSNotification) {
        if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() {
            print("Internet connection OK")
            searchButton.enabled = true
        } else {
            print("Internet connection failed")
            AlertView.displayError(self, title:"Internet Connection Lost", error: "Make sure your device is connected to the internet.")
            searchButton.enabled = false
        }
    }
    
    func checkInternetConnection(){
        if self.reach!.isReachable(){
            print("Internet connection OK")
        } else {
            searchButton.enabled = false
            print("Internet connection FAILED")
            AlertView.displayError(self, title:"No Internet Connection", error: "Make sure your device is connected to the internet.")
        }
    }
    
    func USDARequest(){
        Client.sharedInstance().searchFoodItemsUSDADatabase(searchTextField.text!, dataSouce: dataSource!){(success, foodItemsArray, errorString) in
            if success && foodItemsArray != nil {
                
                for foodItem in foodItemsArray!{
                    let foodName = foodItem["name"] as? String
                    let ndbno = foodItem["ndbno"] as? String
                    
                    self.foodNames.append(foodName!)
                    self.ndbnoList.append(ndbno!)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.searchResultsTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityView.alpha = 0.0
                });
                
            } else {
                performUIUpdatesOnMain{
                    AlertView.displayError(self, title: "Alert", error: errorString!)
                    self.activityIndicator.stopAnimating()
                    self.activityView.alpha = 0.0
                }
            }
        }
    }
    
    
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return foodNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell")! as UITableViewCell
        cell.textLabel?.text = foodNames[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.reach!.isReachable() == false{
            AlertView.displayError(self, title:"No Internet Connection", error: "Make sure your device is connected to the internet.")
        }else{
            activityView.alpha = 1.0
            activityIndicator.startAnimating()
            searchResultsTableView.allowsSelection = false
            searchResultsTableView.deselectRowAtIndexPath(indexPath, animated: true)
            USDANutritionReuqest(ndbnoList[indexPath.row], foodName: foodNames[indexPath.row])
        }
    }

    func USDANutritionReuqest(foodNdbno:String, foodName:String){
        Client.sharedInstance().getFoodNutrientUSDADatabase(foodNdbno) {(success, nutrientsArray, errorString) in
            if success && nutrientsArray != nil{
                let detailedViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailedView") as! DetailedViewController
               
                detailedViewController.foodNdbno = foodNdbno
                detailedViewController.foodName = foodName
                detailedViewController.mealType = self.mealType!
                detailedViewController.foodIndex = self.foodIndex!
                detailedViewController.nutrientsArray = nutrientsArray!
                detailedViewController.date = self.date!
                detailedViewController.isEdit = false
                detailedViewController.delegate = self.mealsViewController

                dispatch_async(dispatch_get_main_queue(),{
                    self.navigationController?.pushViewController(detailedViewController, animated: true)
                });
            }else{
                AlertView.displayError(self, title: "Alert", error: errorString!)
            }
        }
    }
    
    // MARK: Buttons
    let buttonDownImage = UIImage(named: "Button Down")!
    let buttonUpImage = UIImage(named: "Button")!
    
    @IBAction func searchButton(sender: AnyObject) {
        if searchTextField.text == ""{
            AlertView.displayError(self, title: "Alert", error: "Please enter a search term")
        }else{
            activityView.alpha = 1.0
            activityIndicator.startAnimating()
            searchTextField.resignFirstResponder()
            foodNames.removeAll()
            ndbnoList.removeAll()
            USDARequest()
        }
    }
    
    @IBAction func standardButton(sender: AnyObject) {
        brandedButton.isChecked = false
        dataSource = "Standard Reference"
    }
    
    @IBAction func brandedButton(sender: AnyObject) {
        standardButton.isChecked = false
        dataSource = "Branded Food Products"
    }
    
    //MARK: TextView Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == ""{
            AlertView.displayError(self, title: "Alert", error: "Please enter a search term")
        }else{
            textField.resignFirstResponder()
            foodNames.removeAll()
            ndbnoList.removeAll()
            USDARequest()
        }
        return true
    }
}

