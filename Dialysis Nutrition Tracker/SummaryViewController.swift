    //
//  SummaryViewController.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 9/14/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var summaryTable: UITableView!
    @IBOutlet weak var breakfastButton: UIButton!
    @IBOutlet weak var lunchButton: UIButton!
    @IBOutlet weak var dinnerButton: UIButton!
    @IBOutlet weak var snackButton: UIButton!
    @IBOutlet weak var totalButton: UIButton!
    
    var buttons = [UIButton]()
    var breakfast = [Food]()
    var lunch = [Food]()
    var dinner = [Food]()
    var snacks = [Food]()
    var breakfastSummary = [Float]()
    var lunchSummary = [Float]()
    var dinnerSummary = [Float]()
    var snacksSummary = [Float]()
    var summary = [Float]()
    var nutrientNames = [String]()
    var nutrientUnits = [String]()
    
    var overviewValueSummary = Array(count: 4, repeatedValue: Array(count: 4, repeatedValue: Float(0.0)))
    var overviewValue:[Float] = [0.0, 0.0, 0.0, 0.0]
    
    
    var count = 0
    enum ButtonType: Int { case Breakfast = 0, Lunch, Dinner, Snack, Total}

    override func viewDidLoad() {
        super.viewDidLoad()

        summaryTable.delegate = self
        summaryTable.dataSource = self
        buttons = [breakfastButton, lunchButton, dinnerButton, snackButton, totalButton]

        buttonSetup()
        readPropertyList()

        summary = [Float](count: nutrientNames.count, repeatedValue: 0.0)

        breakfastSummary = summaryCalc(breakfast)
        lunchSummary = summaryCalc(lunch)
        dinnerSummary = summaryCalc(dinner)
        snacksSummary = summaryCalc(snacks)
        overviewValueSummary[0] = overviewCalc(breakfast)
        overviewValueSummary[1] = overviewCalc(lunch)
        overviewValueSummary[2] = overviewCalc(dinner)
        overviewValueSummary[3] = overviewCalc(snacks)

        foodCount(ButtonType.Total.rawValue)  // Display summary for all meals as default
        totalButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.summaryTable.layoutMargins = UIEdgeInsetsZero
        self.summaryTable.separatorInset  = UIEdgeInsetsZero
    }
    
    override func viewWillAppear(animated: Bool) {
        totalButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
    }
    
    func readPropertyList(){
        var nutrientDic: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("NutrientList", ofType: "plist") {
            nutrientDic = NSDictionary(contentsOfFile: path)
        }
        if let dict = nutrientDic {
            nutrientNames = dict["NutrientName"] as! Array<String>
            nutrientUnits = dict["NutrientUnit"] as! Array<String>
        }
    }
    
    func summaryCalc(meal:[Food]) -> [Float]{
        var sum = [Float](count: nutrientNames.count, repeatedValue: 0.0)

        for food in meal{
            for i in 0..<food.nutrients.count{
                for j in 0..<nutrientNames.count{
                    if food.nutrients[i].nutrientName == nutrientNames[j]{
                        
                        for measurement in food.nutrients[i].measurements{
                            if measurement.valueForKey("key") as! String == food.servingSize{
                                sum[j] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                            }
                        }
                    }
                }
                           }
        }
        return sum
    }
    
    func overviewCalc(meal:[Food]) -> [Float]{
        var sum:[Float] = [0.0, 0.0, 0.0 ,0.0]
        
        for food in meal{
            for i in 0..<food.nutrients.count{
                if food.nutrients[i].nutrientName == "Phosphorus, P"{
                    for measurement in food.nutrients[i].measurements{
                        if measurement.valueForKey("key") as! String == food.servingSize{
                            sum[0] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                        }
                    }
                }else if food.nutrients[i].nutrientName == "Potassium, K"{
                    for measurement in food.nutrients[i].measurements{
                        if measurement.valueForKey("key") as! String == food.servingSize{
                            sum[1] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                        }
                    }
                }else if food.nutrients[i].nutrientName == "Protein"{
                    for measurement in food.nutrients[i].measurements{
                        if measurement.valueForKey("key") as! String == food.servingSize{
                            sum[2] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                        }
                    }
                }else if food.nutrients[i].nutrientName == "Energy"{
                    for measurement in food.nutrients[i].measurements{
                        if measurement.valueForKey("key") as! String == food.servingSize{
                            sum[3] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                        }
                    }
                }
            }
        }
        return sum
    }
    
    
    
    func foodCount(mealType:Int){
        switch (ButtonType(rawValue: mealType)!) {
        case .Breakfast:
            summary = breakfastSummary
            overviewValue = overviewValueSummary[0]
        case .Lunch:
            summary = lunchSummary
            overviewValue = overviewValueSummary[1]
        case .Dinner:
            summary = dinnerSummary
            overviewValue = overviewValueSummary[2]
        case .Snack:
            summary = snacksSummary
            overviewValue = overviewValueSummary[3]
        case .Total:
            for i in 0..<summary.count{
                summary[i] = breakfastSummary[i] + lunchSummary[i] + dinnerSummary[i] + snacksSummary[i]
            }
            for i in 0..<4{
                overviewValue[i] = overviewValueSummary[0][i] + overviewValueSummary[1][i]
                overviewValue[i] += overviewValueSummary[2][i] + overviewValueSummary[3][i]
            }
        }
    }
    
    // MARK: Buttons
    func buttonSetup(){
        for i in 0..<buttons.count{
            buttons[i].layer.borderWidth = 0.5
            buttons[i].layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
    @IBAction func mealButton(sender: AnyObject) {
        for i in 0..<buttons.count{
            if i == sender.tag{
                buttons[i].backgroundColor = UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
                buttons[i].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

            }else{
                buttons[i].backgroundColor = UIColor.clearColor()
                buttons[i].setTitleColor(UIColor(red: 0.0/255.0, green: 87.0/255.0, blue: 183.0/255.0, alpha: 1.0)
                , forState: UIControlState.Normal)
            }
        }
        foodCount(sender.tag)
        dispatch_async(dispatch_get_main_queue()) {
            self.summaryTable.reloadData()
        }
    }
    @IBAction func infoButton(sender: AnyObject) {
        let message = "The diet restriction varies for each dialysis patient. Please consult a nutritionist to set a goal for your daily limit."
        AlertView.displayError(self, title: "Important Message", error: message)
    }

    // MARK: Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return nutrientNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if indexPath.row  == 3{
            let overviewCell = tableView.dequeueReusableCellWithIdentifier("SummaryOverviewCell", forIndexPath: indexPath) as! SummaryOverviewCell
            overviewCell.Nutrient1.text = "\(overviewValue[0])"
            overviewCell.Unit1.text = "P (mg)"
            
            overviewCell.Nutrient2.text = "\(overviewValue[1])"
            overviewCell.Unit2.text = "K (mg)"
            
            overviewCell.Nutrient3.text = "\(overviewValue[2])"
            overviewCell.Unit3.text = "Protein (g)"
            
            overviewCell.Nutrient4.text = "\(overviewValue[3])"
            overviewCell.Unit4.text = "Energy (kcal)"
            
            overviewCell.selectionStyle = UITableViewCellSelectionStyle.None
            overviewCell.userInteractionEnabled = false
            return overviewCell
        }else{

            let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell")! as! SummaryCell
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.titleLabel.text = nutrientNames[indexPath.row]
            cell.valueLabel.text = "\(summary[indexPath.row]) " + nutrientUnits[indexPath.row]
            
            return cell
        }
    }
}
