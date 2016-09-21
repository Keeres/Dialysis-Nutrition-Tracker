//
//  EditEntryViewController.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/13/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class EditEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var editEntryTableView: UITableView!
    
    var foodNdbno : String?
    var food:Food!
    var nutrients = [Nutrient]()
    var servingSizes = [String]()           // serving sizes available for the food
    var nutrientList = [String]()           // list of nutrients in the food
    var nutrientUnit = [String]()           // units for the nutrients
    var measurementsDictionary = [[String:String]]()
  //  weak var delegate:MyProtocol?
    weak var editViewDelegate: MealsViewController_1?
    var overviewValue : [Float] = [0, 0, 0 ,0]             // index path used retriving nutrient data in overviewCell

    let cellHeight = 44
    var frameHeight:CGFloat?
    var servingSize:String!
    let transition = Animator()
    var numberPadToolBar: UIToolbar?
    var numberOfServings:Float?
    var mealType = String()
    var overviewIndexPath : [Int] = [0, 0, 0 ,0]             // index path used retriving nutrient data in overviewCell
    var updateIndex:Int?
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editEntryTableView.delegate = self
        self.editEntryTableView.dataSource = self
        self.editEntryTableView.layoutMargins = UIEdgeInsetsZero
        self.editEntryTableView.separatorInset  = UIEdgeInsetsZero
    
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditEntryViewController.reloadTable(_:)),name:"reloadTable", object: nil)
        

        self.numberOfServings = food.numberOfServings
        self.servingSize = food.servingSize
        self.updateIndex = food.index
        
        self.getNutrientList()
        self.servingSizesList()
        self.setUpMeasurementsDictionary()
        self.getOverviewValue()
    }
    
    // MARK: Set up
    // Retrieve the serving sizes availabel for the food
    func servingSizesList(){
        // valueForKey return NSSet, use allobject to conver to NSArray
        let measurements = nutrients[0].valueForKey("measurements")?.valueForKey("key")?.allObjects
        for measurement in measurements! {
            servingSizes.append(measurement as! String)
        }
    }
    
    func setUpMeasurementsDictionary(){
        
        for i in 0..<nutrients.count{
            let measurements = nutrients[i].valueForKey("measurements")?.allObjects
            var dict = [String:String]()
            
            for measurement in measurements!{
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
    
    // MARK: Buttons

    @IBAction func servingSizeButton(sender: AnyObject) {
        let servingSizeController = storyboard!.instantiateViewControllerWithIdentifier("ServingSize") as! ServingSizeController
        servingSizeController.servingSizes = self.servingSizes
        servingSizeController.modalPresentationStyle = UIModalPresentationStyle.Custom
        servingSizeController.transitioningDelegate = self
        servingSizeController.editDelegate = self
        servingSizeController.servingSize = self.servingSize
        servingSizeController.delegateInUse = 1
        self.presentViewController(servingSizeController, animated: true, completion: nil)
    }
  
    @IBAction func doneButton(sender: AnyObject) {
      //  print(self.servingSize)
       // print(self.numberOfServings)
       done()

        editViewDelegate!.entryUpdatedServingSize(self.servingSize, newNumberOfServings: self.numberOfServings!, updateIndex: self.updateIndex!)

        let mealsViewController = self.navigationController?.viewControllers[0] as! MealsViewController_1
        self.navigationController?.popToViewController(mealsViewController, animated: true)
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("updateMeals", object: nil)
        }
    }
    
    func addNumberPadToolBar(){
        numberPadToolBar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberPadToolBar!.barStyle = UIBarStyle.Default
        
        let cacelButton =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditEntryViewController.cancel))
        let fillerButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton =   UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditEntryViewController.done))
        cacelButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        doneButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        
        numberPadToolBar!.items = [cacelButton, fillerButton, doneButton]
        
        numberPadToolBar!.sizeToFit()
        numberPadToolBar!.barTintColor = UIColor(red: 0.0, green: 87/255, blue: 182/255, alpha: 1.0)
    
    }
    
    func reloadTable(notification: NSNotification){
        editEntryTableView.reloadData()
    }
    
    // MARK: Delegate function
    func entryUpdatedServingSize(newServingSize: String) {
        self.servingSize = newServingSize
    }
    
    // MARK: Table Delgate Functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let count = nutrientList.count
        return count + 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if indexPath.row == 3{
            return 50
        }else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
      
        if indexPath.row == 0{
            let foodNameCell = tableView.dequeueReusableCellWithIdentifier("EditViewFoodNameCell", forIndexPath: indexPath) as! EditViewFoodNameCell
            foodNameCell.layoutMargins = UIEdgeInsetsZero
            foodNameCell.foodNameLabel.text = food.name
            
            return foodNameCell
            
        }else if indexPath.row == 1{
            let servingSizeCell = tableView.dequeueReusableCellWithIdentifier("EditViewServingSizeCell", forIndexPath: indexPath) as! EditViewServingSizeCell
            servingSizeCell.layoutMargins = UIEdgeInsetsZero
            servingSizeCell.servingSizeLabel.text = "Serving Size"
            servingSizeCell.servingSizeButton.setTitle(servingSize, forState: UIControlState.Normal)
            servingSizeCell.servingSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;

            return servingSizeCell
            
        }else if indexPath.row == 2{
            let numberOfSevingsCell = tableView.dequeueReusableCellWithIdentifier("EditViewNumberOfServingsCell", forIndexPath: indexPath) as! EditViewNumberOfServingsCell
            numberOfSevingsCell.numberOfServingsTextField.text = "\(numberOfServings!)"

            numberOfSevingsCell.layoutMargins = UIEdgeInsetsZero
            numberOfSevingsCell.numberOfServingsTextField.keyboardType = UIKeyboardType.DecimalPad
            numberOfSevingsCell.numberOfServingsTextField.delegate = self;
            addNumberPadToolBar()
            numberOfSevingsCell.numberOfServingsTextField.inputAccessoryView = numberPadToolBar
       

            return numberOfSevingsCell
        }else if indexPath.row == 3{
            let overviewCell = tableView.dequeueReusableCellWithIdentifier("EditViewOverviewCell", forIndexPath: indexPath) as! EditViewOverviewCell
            overviewCell.layoutMargins = UIEdgeInsetsZero
            
            let value1 = Float(measurementsDictionary[overviewIndexPath[0]][servingSize]!)! * numberOfServings!
            overviewCell.nutrient1.text = "\(value1)"
            overviewCell.nutrientUnit1.text = "P" + " " +  "(" + nutrientUnit[overviewIndexPath[0]] + ")"
            
            let value2 = Float(measurementsDictionary[overviewIndexPath[1]][servingSize]!)! * numberOfServings!
            overviewCell.nutrient2.text = "\(value2)"
            overviewCell.nutrientUnit2.text = "K" + " " +  "(" + nutrientUnit[overviewIndexPath[1]] + ")"
            
            let value3 = Float(measurementsDictionary[overviewIndexPath[2]][servingSize]!)! * numberOfServings!
            overviewCell.nutrient3.text = "\(value3)"
            overviewCell.nutrientUnit3.text = "Protein" + " " +  "(" + nutrientUnit[overviewIndexPath[2]] + ")"
            
            let value4 = Float(measurementsDictionary[overviewIndexPath[3]][servingSize]!)! * numberOfServings!
            overviewCell.nutrient4.text = "\(value4)"
            overviewCell.nutrientUnit4.text = "Energy" + " " +  "(" + nutrientUnit[overviewIndexPath[3]] + ")"
            
            return overviewCell
        }else{
            let nutrientCell = tableView.dequeueReusableCellWithIdentifier("EditViewNutrientCell", forIndexPath: indexPath) as! EditViewNutrientCell
            nutrientCell.layoutMargins = UIEdgeInsetsZero
         
            nutrientCell.titleLabel.text = nutrientList[indexPath.row-3] + " " +  "(" + nutrientUnit[indexPath.row-3] + ")"
            let value = Float(measurementsDictionary[indexPath.row-3][servingSize]!)! * numberOfServings!
            nutrientCell.valueLabel.text = "\(value)"
            
            return nutrientCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
  
    
    // MARK: Texfield delegate
    var oldTextField = ""
    
    func done(){
        let cell = editEntryTableView.cellForRowAtIndexPath( NSIndexPath(forRow: 2, inSection: 0)) as! EditViewNumberOfServingsCell
        numberOfServings = Float(cell.numberOfServingsTextField.text!)!
        self.editEntryTableView.reloadData()
        cell.numberOfServingsTextField.resignFirstResponder()
    }
    
    func cancel(){
        let cell = editEntryTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! EditViewNumberOfServingsCell
        cell.numberOfServingsTextField.text = oldTextField
        cell.numberOfServingsTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let cell = editEntryTableView.cellForRowAtIndexPath( NSIndexPath(forRow: 2, inSection: 0)) as! EditViewNumberOfServingsCell
        
        oldTextField =  cell.numberOfServingsTextField.text!
        textField.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditEntryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
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
extension EditEntryViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
                             sourceController source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            transition.originFrame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height)
            let count = servingSizes.count
            transition.height = (Double(count)+1) * Double(cellHeight)
            transition.presenting = true
            
            return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}