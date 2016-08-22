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
    weak var delegate:MyProtocol?
    var mealsViewController: MealsViewController_1? = MealsViewController_1()

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
        self.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    func USDARequest(){
        Client.sharedInstance().searchFoodItemsUSDADatabase(searchTextField.text!){(foodItemsArray, errorString) in
         //   self.foodSearchResults = foodItemsArray!
            
            if foodItemsArray != nil {
                
                for foodItem in foodItemsArray!{
                    let foodName = foodItem["name"] as? String
                    let ndbno = foodItem["ndbno"] as? String
    
                    self.foodNames.append(foodName!)
                    self.ndbnoList.append(ndbno!)
                }
            } else if foodItemsArray == nil{
                // Insert Alert text stating search returned no results
            }
            dispatch_async(dispatch_get_main_queue(),{
                self.searchResultsTableView.reloadData()
            });
        }
    }
    
    
    // MARK: Table Delgate Functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
     //   let row = foodsSearch.count
        let row = foodNames.count
        print(row)
        return row
    }
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell")! as UITableViewCell
          cell.textLabel?.text = foodNames[indexPath.row]
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailedViewController = storyboard!.instantiateViewControllerWithIdentifier("DetailedView") as! DetailedViewController
        
        detailedViewController.foodNdbno = ndbnoList[indexPath.row]
        detailedViewController.mealType = self.mealType!
        detailedViewController.foodIndex = self.foodIndex!
        detailedViewController.delegate = mealsViewController
        self.navigationController?.pushViewController(detailedViewController, animated: true)
    }
    
    // MARK: Buttons
    @IBAction func searchButton(sender: AnyObject) {
        USDARequest()
    }
}

