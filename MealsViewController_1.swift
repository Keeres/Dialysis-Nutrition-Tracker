//
//  MealsViewController_1.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/4/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class MealsViewController_1: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MyProtocol {
    
    @IBOutlet weak var mealsTableView_1: UITableView!
    
    var foods:[Food]?               // All Food consumed, out of order in terms of breakfast, lunch, dinner
    var loadFromDisk:Bool?
    var breakfast = [Food]()
    var lunch = [Food]()
    var dinner = [Food]()
    var meals = [[Food]]()          // contains breakfast, lunch, and dinner array
    var nutrientList : [[String]]?
    var addedFood:Food?
    var index:Int?
    var foodIndex:Int?
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView_1.delegate = self
        mealsTableView_1.dataSource = self
        meals = [breakfast, lunch , dinner]
        self.mealsTableView_1.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        foodIndex = 0

        let fetched = fetchedResultsController
        fetched.delegate = self
        try! fetched.performFetch()
        
        foods = fetched.fetchedObjects as? [Food]!
   
        if foods!.count != 0{
            foodIndex = foods!.count
            organizeMeals()
            getMaxNutrientCount(foods!)
        }
    
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MealsViewController_1.updateMeals(_:)), name:"updateMeals", object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.mealsTableView_1.layoutMargins = UIEdgeInsetsZero
        self.mealsTableView_1.separatorInset  = UIEdgeInsetsZero
    }
    
    // MARK: Buttons
    @IBAction func BreakfastAddFoodButton(sender: AnyObject) {
        let searchViewController = storyboard?.instantiateViewControllerWithIdentifier("searchViewController") as! SearchViewController
        searchViewController.mealType = "breakfast"
        searchViewController.foodIndex = self.foodIndex
        searchViewController.delegate = self
        
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @IBAction func lunchAddFoodButton(sender: AnyObject) {
        let searchViewController = storyboard?.instantiateViewControllerWithIdentifier("searchViewController") as! SearchViewController
        searchViewController.mealType = "lunch"
        searchViewController.foodIndex = self.foodIndex
        searchViewController.delegate = self
        self.navigationController?.pushViewController(searchViewController, animated: true)

    }
    
    @IBAction func dinnerAddFoodButton(sender: AnyObject) {
        let searchViewController = storyboard?.instantiateViewControllerWithIdentifier("searchViewController") as! SearchViewController
        searchViewController.mealType = "dinner"
        searchViewController.foodIndex = self.foodIndex
        searchViewController.delegate = self
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }

    func summaryButton(sender:UIButton!){
        let summaryController = storyboard!.instantiateViewControllerWithIdentifier("SummaryView") as! SummaryViewController
        summaryController.breakfast = self.breakfast
        summaryController.lunch = self.lunch
        summaryController.dinner = self.dinner
        summaryController.nutrientList = self.nutrientList!
        self.navigationController?.pushViewController(summaryController, animated: true)
    }

    // MARK: Organize Meals
    func organizeMeals(){
        for food in self.foods!{
            if food.mealType == "breakfast"{
                self.breakfast.append(food)
            }else if food.mealType == "lunch"{
                self.lunch.append(food)
            }else {
                self.dinner.append(food)
            }
        }
        meals = [breakfast, lunch, dinner]
    }
    
    func getMaxNutrientCount(foods:[Food]){
        var index = 0
        var maxNurientCount = 0
        for i in 0..<foods.count{
            if foods[i].nutrients.count > maxNurientCount{
                maxNurientCount = foods[i].nutrients.count
                index = i
            }
        }
        getNutrientList(foods[index].nutrients)
    }
    
    func getNutrientList(nutrients:[Nutrient]){
        
        nutrientList = [[String]](count: nutrients.count, repeatedValue: [String](count: 2, repeatedValue: ""))

        for i in 0..<nutrients.count{
            nutrientList![i][0] = nutrients[i].nutrientName
            print(nutrients[i].nutrientName)
            nutrientList![i][1] = nutrients[i].unit
        }
    }
    
    // MARK: NSNotification func
    // updates serving size that user seleceted
    func updateMeals(notification: NSNotification){
        meals = [breakfast, lunch, dinner]

        dispatch_async(dispatch_get_main_queue(),{
            self.mealsTableView_1.reloadData()
        });
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.mealsTableView_1.reloadData()
    }
   
    // Mark: Fetch Results
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Food")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = nil
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
    
    // MARK: MyProtocol functions

    func addMeal(meal: Food) {

      //  self.addedFood = meal
        //self.foods?.append(self.addedFood!)
    }
    
    func entryUpdatedServingSize(newServingSize: String, newNumberOfServings:Float, updateIndex:Int) {

        self.foods![updateIndex].servingSize = newServingSize
        self.foods![updateIndex].numberOfServings = newNumberOfServings
        foodIndex = self.foods?.count
        do {
            try self.sharedContext.save()
        } catch {
            print("save to core data failed")
        }
    }

    
    // MARK: Tableview Delgates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        
        switch (section) {
        case 0:
            headerCell.headerLabel.text = "Breakfast";
        case 1:
            headerCell.headerLabel.text = "Lunch";
        case 2:
            headerCell.headerLabel.text = "Dinner";
        default:
            headerCell.headerLabel.text = " ";
        }
        
        return headerCell
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return meals[section].count + 1
    }
  
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView : UIView?
        footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
        footerView?.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)

        if section == 2 {
            footerView?.frame = CGRectMake(0, 0, tableView.frame.size.width, 50)
         //   footerView?.backgroundColor = UIColor.blueColor()
            let dunamicButton = UIButton(type: UIButtonType.System) as UIButton
            
         //   let dunamicButton = UIButton(frame: CGRectMake(footerView!.center.x, footerView!.center.y, 200, 20))
            dunamicButton.backgroundColor = UIColor.darkGrayColor()
            dunamicButton.setTitle("Nutrition Summary", forState: UIControlState.Normal)
            dunamicButton.frame = CGRectMake(footerView!.center.x/2, footerView!.center.y/2,  tableView.frame.size.width/2, 30)

          //  dunamicButton.addTarget(self, action: Selector("buttonTouched"), forControlEvents: UIControlEvents.TouchUpInside)
            dunamicButton.addTarget(self, action: #selector(MealsViewController_1.summaryButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            footerView?.addSubview(dunamicButton)
        }

        
        
        return footerView
    }
    
  
   
    
 //   func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
   //     if section == 3{
     //       print(section)
       // }
    //}
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 50
        }else{
            return 10
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if  indexPath.row == meals[indexPath.section].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddBreakfastCell")! as! AddBreakfastCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
         //   cell.addBreakfastButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
            
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("BreakfastCell")! as! BreakfastCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.foodLabel!.text = meals[indexPath.section][indexPath.row].name
            cell.foodLabel!.numberOfLines = 2
            cell.foodLabel!.minimumScaleFactor = 0.5
            cell.foodLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.foodLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            cell.foodLabel!.adjustsFontSizeToFitWidth = true
            
            cell.servingSizeLabel.text = meals[indexPath.section][indexPath.row].servingSize
            cell.numberOfServingsLabel.text = "\(meals[indexPath.section][indexPath.row].numberOfServings)"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.section)

        if  indexPath.row == meals[indexPath.section].count {
            let searchViewController = storyboard?.instantiateViewControllerWithIdentifier("searchViewController") as! SearchViewController
            switch (indexPath.section) {
            case 0:
                searchViewController.mealType = "breakfast"
            case 1:
                searchViewController.mealType = "lunch"
            case 2:
                searchViewController.mealType = "dinner"
            default:
                searchViewController.mealType = "none"
            }
            searchViewController.foodIndex = self.foodIndex
            searchViewController.delegate = self
            self.navigationController?.pushViewController(searchViewController, animated: true)
        }else{
            
            let editEntryController = storyboard!.instantiateViewControllerWithIdentifier("EditEntry") as! EditEntryViewController
            print(meals[indexPath.section][indexPath.row].index)
            editEntryController.food = meals[indexPath.section][indexPath.row]
            editEntryController.nutrients = meals[indexPath.section][indexPath.row].nutrients
            editEntryController.editViewDelegate = self
            
            self.navigationController?.pushViewController(editEntryController, animated: true)
        }
    }
}
