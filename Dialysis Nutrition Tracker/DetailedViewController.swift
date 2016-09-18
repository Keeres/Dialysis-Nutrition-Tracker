//
//  DetailedViewController.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/7/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class DetailedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var foodNdbno : String?
    var foodIndex : Int?
    var foodName: String?
    var numberOfServings: Float?
    var servingSize: String?
    var mealType: String?
    
    var food:Food!
    var nutrients = [Nutrient]()
    var servingSizes = [String]()           // serving sizes available for the food
    var nutrientList = [String]()           // list of nutrients in the food
    var nutrientUnit = [String]()           // units for the nutrients
    var nutrientsArray = [[String:AnyObject]]()
    var measurementsDictionary = [[String:String]]()
    var overviewValue : [Float] = [0, 0, 0 ,0]             // index path used retriving nutrient data in overviewCell

    weak var delegate:MyProtocol?
    
    let transition = Animator()
    var numberPadToolBar: UIToolbar?
 
    @IBOutlet weak var detailedTableView: UITableView!
    @IBOutlet var detailedView: UIView!
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(foodName)
        self.detailedTableView.delegate = self
        self.detailedTableView.dataSource = self
        self.detailedTableView.layoutMargins = UIEdgeInsetsZero
        self.detailedTableView.separatorInset  = UIEdgeInsetsZero
        
        self.navigationItem.title = "Add Food"
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        numberOfServings = 1
    
        parseNutrientsArray()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailedViewController.updateTable(_:)),name:"updateTable", object: nil)
    }
    
    func parseNutrientsArray(){
        
        self.food = Food(name: foodName!, ndbno: foodNdbno!, mealType: self.mealType!, index: self.foodIndex!, numberOfServings:self.numberOfServings!, context: self.sharedContext)
            
            for nutrition in nutrientsArray{
                let name = nutrition["name"] as? String
                let unit = nutrition["unit"] as? String
                let nutrient = Nutrient(nutrientName: name!, unit: unit!, context: self.sharedContext)
                
                guard let measurementsList = nutrition["measures"] as? [[String:AnyObject]] else {
                    print("error parsing measurements")
                    return
                }
                for measurement in measurementsList{
                    let label = measurement["label"] as? String
                    let value = measurement["value"] as? String
                    let measure = Measurement(key: label!, value: value!, context:self.sharedContext)
                    
                    measure.nutrient = nutrient
                }
                nutrient.food = self.food
                self.nutrients.append(nutrient)
            }
        
        self.getNutrientList()
        self.servingSizesList()
        self.setUpMeasurementsDictionary()
        self.getOverviewValue()
        
            dispatch_async(dispatch_get_main_queue(),{
              self.detailedTableView.reloadData()
        });
    }

    // MARK: NSNotification func
    // updates serving size that user seleceted
    func updateTable(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(),{
            self.detailedTableView.reloadData()
        });
    }
    
    // MARK: Set up
    // Retrieve the serving sizes available for the food
    func servingSizesList(){
        // valueForKey return NSSet, use allobject to conver to NSArray
        let measurements = nutrients[0].valueForKey("measurements")?.valueForKey("key")?.allObjects
        for measurement in measurements! {
            servingSizes.append(measurement as! String)
        }
        servingSize = servingSizes[0]
    }
    
    func setUpMeasurementsDictionary(){
        for i in 0..<nutrients.count{
            let measurements = nutrients[i].valueForKey("measurements")?.allObjects
            var dict = [String:String]()
            for measurement in measurements!{

              //  measurementsValue.append(Float(measurement.valueForKey("value") as! String)!)
                dict[measurement.valueForKey("key") as! String] = measurement.valueForKey("value") as? String

            }
            measurementsDictionary.append(dict)
        }
    }
    
    // retreive the list of nutrients from the food
    func getNutrientList(){
        for nutrient in nutrients{
            nutrientList.append(nutrient.nutrientName)
            nutrientUnit.append(nutrient.unit)
        }
    }
    
    func getOverviewValue(){
        for i in 0..<nutrientList.count{
            if nutrientList[i] == "Phosphorus, P"{
                overviewValue[0] = Float(measurementsDictionary[i][servingSize!]!)!
            }else if nutrientList[i] == "Potassium, K"{
                overviewValue[1] = Float(measurementsDictionary[i][servingSize!]!)!
            }else if nutrientList[i] == "Protein"{
                overviewValue[2] = Float(measurementsDictionary[i][servingSize!]!)!
            }else if nutrientList[i] == "Energy"{
                overviewValue[3] = Float(measurementsDictionary[i][servingSize!]!)!
            }
        }
    }
    
    func addNumberPadToolBar(){
        numberPadToolBar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberPadToolBar!.barStyle = UIBarStyle.Default
        
        let cacelButton =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailedViewController.cancel))
        let fillerButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton =   UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailedViewController.done))
        cacelButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        doneButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        numberPadToolBar!.items = [cacelButton, fillerButton, doneButton]
        numberPadToolBar!.sizeToFit()
        numberPadToolBar!.barTintColor = UIColor(red: 0.0, green: 87/255, blue: 182/255, alpha: 1.0)
    }
    
    // MARK: Buttons
    
    // allows user to select desired serving size
    @IBAction func servingSizeButton(sender: AnyObject) {
        let servingSizeController = storyboard!.instantiateViewControllerWithIdentifier("ServingSize") as! ServingSizeController
        servingSizeController.servingSizes = self.servingSizes
        servingSizeController.modalPresentationStyle = UIModalPresentationStyle.Custom
        servingSizeController.transitioningDelegate = self
        servingSizeController.delegate = self
        servingSizeController.servingSize = self.servingSize
        servingSizeController.delegateInUse = 0
        self.presentViewController(servingSizeController, animated: true, completion: nil)
    }

    @IBAction func addButton(sender: AnyObject) {
        food.setValue(self.numberOfServings, forKey: "numberOfServings")
        food.setValue(self.servingSize, forKey: "servingSize")

        do {
            try self.sharedContext.save()
        } catch {
            print("save to core data failed")
        }
        
        let mealsViewController = self.navigationController?.viewControllers[0] as! MealsViewController_1
        if self.food.mealType == "breakfast" {
            mealsViewController.breakfast.append(self.food)
        }else if self.food.mealType == "lunch" {
            mealsViewController.lunch.append(self.food)
        }else if self.food.mealType == "dinner" {
            mealsViewController.dinner.append(self.food)
        }
        mealsViewController.foods?.append(food)
        mealsViewController.foodIndex = mealsViewController.foods?.count
        self.navigationController?.popToViewController(mealsViewController, animated: true)
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("updateMeals", object: nil)
        }
    }
    
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let count = nutrientList.count + 4

        return count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if indexPath.row == 3{
            return 50
        }else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //let cell = UITableViewCell()
        //return cell
        
        if indexPath.row  == 0{
            let foodNameCell = tableView.dequeueReusableCellWithIdentifier("FoodNameCell", forIndexPath: indexPath) as! FoodNameCell
            foodNameCell.layoutMargins = UIEdgeInsetsZero
            foodNameCell.foodNameLabel.text = foodName
            foodNameCell.selectionStyle = UITableViewCellSelectionStyle.None
            foodNameCell.userInteractionEnabled = false
            
            return foodNameCell
            
        }else if indexPath.row  == 1{
            let servingSizeCell = tableView.dequeueReusableCellWithIdentifier("ServingSizeCell", forIndexPath: indexPath) as! ServingSizeCell
            servingSizeCell.layoutMargins = UIEdgeInsetsZero
            servingSizeCell.titleLabel.text = "Serving Size"
            servingSizeCell.servingSizeButton.setTitle(servingSize, forState: UIControlState.Normal)
            servingSizeCell.servingSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
            servingSizeCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return servingSizeCell
            
        }else if indexPath.row  == 2{
            let numberOfSevingsCell = tableView.dequeueReusableCellWithIdentifier("NumberOfServingsCell", forIndexPath: indexPath) as! NumberOfServingsCell
            numberOfSevingsCell.layoutMargins = UIEdgeInsetsZero
            numberOfSevingsCell.NumberOfServingsTextField.keyboardType = UIKeyboardType.DecimalPad
            numberOfSevingsCell.NumberOfServingsTextField.delegate = self;
            addNumberPadToolBar()
            numberOfSevingsCell.NumberOfServingsTextField.inputAccessoryView = numberPadToolBar
            numberOfSevingsCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return numberOfSevingsCell
        }else if indexPath.row  == 3{
            let overviewCell = tableView.dequeueReusableCellWithIdentifier("OverviewCell", forIndexPath: indexPath) as! OverviewCell
            overviewCell.layoutMargins = UIEdgeInsetsZero
            getOverviewValue()
            
            overviewCell.nutrient1.text = "\(overviewValue[0]*numberOfServings!)"
            overviewCell.nutrientUnit1.text = "P (mg)"
            
            overviewCell.nutrient2.text = "\(overviewValue[1]*numberOfServings!)"
            overviewCell.nutrientUnit2.text = "K (mg)"

            overviewCell.nutrient3.text = "\(overviewValue[2]*numberOfServings!)"
            overviewCell.nutrientUnit3.text = "Protein (g)"

            overviewCell.nutrient4.text = "\(overviewValue[3]*numberOfServings!)"
            overviewCell.nutrientUnit4.text = "Energy (kcal)"

            overviewCell.selectionStyle = UITableViewCellSelectionStyle.None
            overviewCell.userInteractionEnabled = false
            
            return overviewCell
        }else{
            let nutrientCell = tableView.dequeueReusableCellWithIdentifier("NutrientCell", forIndexPath: indexPath) as! NutrientCell
            nutrientCell.layoutMargins = UIEdgeInsetsZero
            nutrientCell.titleLabel.text = nutrientList[indexPath.row-4] + " " +  "(" + nutrientUnit[indexPath.row-4] + ")"
            let value = Float(measurementsDictionary[indexPath.row-4][servingSize!]!)! * numberOfServings!
            nutrientCell.valueLabel.text = "\(value)"
            nutrientCell.selectionStyle = UITableViewCellSelectionStyle.None
            nutrientCell.userInteractionEnabled = false
            
            return nutrientCell
        }
    }

    // MARK: Animation Delegate
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return 0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    // MARK: Delegate function
    func updatedServingSize(newServingSize: String) {
        self.servingSize = newServingSize
    }
    
    // MARK: Texfield delegate
    var oldTextField = ""
    
    func done(){
        let cell = detailedTableView.cellForRowAtIndexPath( NSIndexPath(forRow: 2, inSection: 0)) as! NumberOfServingsCell
        numberOfServings = Float(cell.NumberOfServingsTextField.text!)!
        self.detailedTableView.reloadData()
            cell.NumberOfServingsTextField.resignFirstResponder()
    }
    
    func cancel(){
        let cell = detailedTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! NumberOfServingsCell
        cell.NumberOfServingsTextField.text = oldTextField
        cell.NumberOfServingsTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
         let cell = detailedTableView.cellForRowAtIndexPath( NSIndexPath(forRow: 2, inSection: 0)) as! NumberOfServingsCell
        
        oldTextField =  cell.NumberOfServingsTextField.text!
        textField.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailedViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(note : NSNotification) -> Void{
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
   
            UIView.animateWithDuration(((note.userInfo! as NSDictionary).objectForKey(UIKeyboardAnimationCurveUserInfoKey)?.doubleValue)!, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.view.frame = CGRectOffset(self.view.frame, 0, 0)
                }, completion: { (complete) -> Void in
                    print("Complete")
            })
        }
    }
}


// For custom transition
extension DetailedViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
                             sourceController source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            transition.originFrame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height)
            let count = servingSizes.count
            transition.height = (Double(count)+1) * Double(44)
            transition.presenting = true
            
            return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

protocol MyProtocol: class {
    func addMeal(mealType:Food)
}


