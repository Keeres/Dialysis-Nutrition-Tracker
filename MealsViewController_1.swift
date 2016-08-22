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
    
    var cellCount:Int?
    var foods:[Food]?
    var loadFromDisk:Bool?
    var breakfast = [Food]()
    var lunch = [Food]()
    var dinner = [Food]()
    var meals = [[Food]]()
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
        cellCount = 2                                       // defualt number of cells
        mealsTableView_1.tableFooterView = UIView()         // hides empty cells
        self.mealsTableView_1.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        foodIndex = 0

        let fetched = fetchedResultsController
        fetched.delegate = self
        try! fetched.performFetch()
        
        foods = fetched.fetchedObjects as? [Food]!
   
        if foods!.count != 0{
            foodIndex = foods!.count
            print(foodIndex)
            print(foods?.count)
      //      print(foods![0].servingSize)
            print(foods![0].name)

            print(foods![0].servingSize)

            organizeMeals()
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

    // MARK: Organize Meals
    func organizeMeals(){
        //  if foods!.count != 0 {
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
        print(updateIndex)
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

        return meals[section].count + 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if indexPath.row == meals[indexPath.section].count + 1{
            return 15
        }else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        if indexPath.section == 0 && indexPath.row == meals[indexPath.section].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddBreakfastCell")! as! AddBreakfastCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.addBreakfastButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;


            return cell
        }else if indexPath.section == 1 && indexPath.row == meals[indexPath.section].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddLunchCell")! as! AddLunchCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.addLunchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;

            return cell
        }else if indexPath.section == 2 && indexPath.row == meals[indexPath.section].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddDinnerCell")! as! AddDinnerCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.addDinnerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;

            return cell
        }else if indexPath.row == meals[indexPath.section].count + 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SeparatorCell")! as UITableViewCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.userInteractionEnabled = false

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
        let editEntryController = storyboard!.instantiateViewControllerWithIdentifier("EditEntry") as! EditEntryViewController
        print(meals[indexPath.section][indexPath.row].index)
        editEntryController.food = meals[indexPath.section][indexPath.row]
        editEntryController.nutrients = meals[indexPath.section][indexPath.row].nutrients
        editEntryController.editViewDelegate = self
        
      
        
        self.navigationController?.pushViewController(editEntryController, animated: true)
    }
}
