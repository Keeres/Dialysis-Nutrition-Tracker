//
//  SearchViewController.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/1/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var foodSearchResults = [[String:AnyObject]]()
    var foodNames = [String]()
    var ndbnoList = [String]()
    var mealType = String?()
    var foodIndex = Int?()
    var date: String?
    var dataSource:String?
    
 //   weak var delegate:MyProtocol?
    var mealsViewController: MealsViewController_1? = MealsViewController_1()

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var standardButton: RadioButton!
    @IBOutlet weak var brandedButton: RadioButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
        self.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        standardButton.isChecked = true
        dataSource = "Standard Reference"
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
                });
                
            } else {
                AlertView.displayError(self, error: errorString!)
            }
        }
    }
    
    
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return foodNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell")! as UITableViewCell
        cell.textLabel!.numberOfLines = 2
        cell.textLabel!.minimumScaleFactor = 1
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = foodNames[indexPath.row]
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;//Choose your custom row height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        USDANutritionReuqest(ndbnoList[indexPath.row], foodName: foodNames[indexPath.row])
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
                AlertView.displayError(self, error: errorString!)
            }
        }
    }
    
    // MARK: Buttons
    let buttonDownImage = UIImage(named: "Button Down")!
    let buttonUpImage = UIImage(named: "Button")!
    @IBAction func searchButton(sender: AnyObject) {
        foodNames.removeAll()
        ndbnoList.removeAll()
        USDARequest()
    }
    @IBAction func standardButton(sender: AnyObject) {
        //standardButton.isChecked = true
        brandedButton.isChecked = false
        dataSource = "Standard Reference"
    }
    
    
    @IBAction func brandedButton(sender: AnyObject) {
        standardButton.isChecked = false
       // brandedButton.isChecked = true
        dataSource = "Branded Food Products"
    }
    
}

