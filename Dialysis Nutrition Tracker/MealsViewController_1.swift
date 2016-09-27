//
//  MealsViewController_1.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/4/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class MealsViewController_1: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mealsTableView_1: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var foods:[Food]?               // All Food consumed, out of order in terms of breakfast, lunch, dinner, snacks
    var breakfast = [Food]()
    var lunch = [Food]()
    var dinner = [Food]()
    var snacks = [Food]()
    var meals = [[Food]]()          // contains breakfast, lunch, dinner, and snacks array
    var nutrientList : [[String]]?
    var addedFood:Food?
    var date:String?
    var foodIndex:Int?
    var dayChange = 0
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView_1.delegate = self
        mealsTableView_1.dataSource = self
        meals = [breakfast, lunch , dinner, snacks]
        self.mealsTableView_1.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        foodIndex = 0
        
        getDate()
        performFetch()
        
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
 
    // MARK: Organize Meals
    func organizeMeals(){
        for food in self.foods!{
            if food.mealType == "breakfast"{
                self.breakfast.append(food)
            }else if food.mealType == "lunch"{
                self.lunch.append(food)
            }else if food.mealType == "dinner"{
                self.dinner.append(food)
            }else{
                self.snacks.append(food)
            }
        }
        meals = [breakfast, lunch, dinner, snacks]
    }

    // MARK: NSNotification func
    // updates serving size that user seleceted
    func updateMeals(notification: NSNotification){
        meals = [breakfast, lunch, dinner, snacks]

        dispatch_async(dispatch_get_main_queue(),{
            self.mealsTableView_1.reloadData()
        });
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.mealsTableView_1.reloadData()
    }
    
    // MARK: Date
    var currentDate: NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: dayChange, toDate: NSDate(), options: [])!
    }
    
    func getDate(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
        date = dateFormatter.stringFromDate(currentDate)
        dateLabel.text = date
    }
    
    // Mark: Fetch Results
    func fetchRequest(date: String) -> NSFetchedResultsController{
        let fetchRequest = NSFetchRequest(entityName: "Food")
        
        fetchRequest.predicate = NSPredicate(format: "(date == %@)", date)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }
    
    
    func performFetch(){
        let fetched = fetchRequest(date!)
        fetched.delegate = self
        try! fetched.performFetch()
        
        foods = fetched.fetchedObjects as? [Food]!
        if foods!.count != 0{
            foodIndex = foods!.count
            organizeMeals()
        }
    }
    
    // MARK: Buttonn
    func summaryButton(sender:UIButton!){
        let summaryController = storyboard!.instantiateViewControllerWithIdentifier("SummaryView") as! SummaryViewController
        summaryController.breakfast = self.breakfast
        summaryController.lunch = self.lunch
        summaryController.dinner = self.dinner
        summaryController.snacks = self.snacks

        self.navigationController?.pushViewController(summaryController, animated: true)
    }

    @IBAction func dateButton(sender: AnyObject) {
        if sender.tag == 0{
            dayChange -= 1
        }else if(sender.tag == 1){
            dayChange += 1
        }
        removeData()
        getDate()
        performFetch()
        mealsTableView_1.reloadData()
    }

    func entryUpdatedServingSize(newServingSize: String, newNumberOfServings:Float, updateIndex:Int) {
        for food in foods!{
            if food.index == updateIndex{
                food.servingSize = newServingSize
                food.numberOfServings = newNumberOfServings
            }
        }
    //    self.foods![updateIndex].servingSize = newServingSize
    //    self.foods![updateIndex].numberOfServings = newNumberOfServings
      //  foodIndex = self.foods?.count
        do {
            try self.sharedContext.save()
        } catch {
            print("save to core data failed")
        }
    }

    func removeData(){
        for i in 0..<meals.count{
            meals[i].removeAll()
        }
        foods?.removeAll()
        breakfast.removeAll()
        lunch.removeAll()
        dinner.removeAll()
        snacks.removeAll()
    }
    
    // MARK: Tableview Delgates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
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
        case 3:
            headerCell.headerLabel.text = "Snacks";
        default:
            headerCell.headerLabel.text = " ";
        }
        headerCell.contentView.backgroundColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)

        return headerCell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return meals[section].count + 1
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView : UIView?
        footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
        footerView?.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)

        if section == 3 {
            footerView?.frame = CGRectMake(0, 0, tableView.frame.size.width, 50)
            let summaryButton = UIButton(type: UIButtonType.System) as UIButton
            
            summaryButton.backgroundColor = UIColor.darkGrayColor()
            summaryButton.tintColor = UIColor.whiteColor()
            summaryButton.setTitle("Nutrition Summary", forState: UIControlState.Normal)
            summaryButton.frame = CGRectMake(footerView!.center.x/2, footerView!.center.y/2,  tableView.frame.size.width/2, 30)
            summaryButton.layer.cornerRadius = 5; // this value vary as per your desire
            summaryButton.clipsToBounds = true;
            summaryButton.addTarget(self, action: #selector(MealsViewController_1.summaryButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            footerView?.addSubview(summaryButton)
        }
        
        return footerView!
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
            return 50
        }else{
            return 10
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if  indexPath.row == meals[indexPath.section].count {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddFoodCell")! as! AddFoodCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None            
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("MealsCell")! as! MealsCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.foodLabel!.text = meals[indexPath.section][indexPath.row].name
            cell.foodLabel!.numberOfLines = 2
            cell.foodLabel!.minimumScaleFactor = 1
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

        if  indexPath.row == meals[indexPath.section].count {
            let searchViewController = storyboard?.instantiateViewControllerWithIdentifier("searchViewController") as! SearchViewController
            switch (indexPath.section) {
            case 0:
                searchViewController.mealType = "breakfast"
            case 1:
                searchViewController.mealType = "lunch"
            case 2:
                searchViewController.mealType = "dinner"
            case 3:
                searchViewController.mealType = "snacks"
            default:
                searchViewController.mealType = "none"
            }
            searchViewController.foodIndex = self.foodIndex
            searchViewController.date = self.date;
            self.navigationController?.pushViewController(searchViewController, animated: true)
        }else{
            let detailedViewController = storyboard!.instantiateViewControllerWithIdentifier("DetailedView") as! DetailedViewController
            detailedViewController.food = meals[indexPath.section][indexPath.row]
            detailedViewController.nutrients = meals[indexPath.section][indexPath.row].nutrients
            detailedViewController.isEdit = true
            detailedViewController.delegate = self
            
            self.navigationController?.pushViewController(detailedViewController, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            let food = meals[indexPath.section][indexPath.row]
         
            switch (indexPath.section) {
            case 0:
                breakfast.removeAtIndex(indexPath.row)
            case 1:
                lunch.removeAtIndex(indexPath.row)
            case 2:
                dinner.removeAtIndex(indexPath.row)
            case 3:
                snacks.removeAtIndex(indexPath.row)
            default:
                    print("error")
            }
            meals[indexPath.section].removeAtIndex(indexPath.row)
            sharedContext.deleteObject(food)

            do {
                try self.sharedContext.save()
            } catch {
                print("save to core data failed")
            }

            mealsTableView_1.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
