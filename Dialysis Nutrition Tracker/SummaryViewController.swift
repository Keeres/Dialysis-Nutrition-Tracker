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
    var breakfastSummary = [Float]()
    var lunchSummary = [Float]()
    var dinnerSummary = [Float]()
    var summary = [Float]()
    var nutrientNames = [String]()
    var nutrientUnits = [String]()

    var count = 0
    var measurementsDictionary = [[String:String]]()
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
            // for nutrient in food.nutrients{
            for i in 0..<food.nutrients.count{
                for j in 0..<nutrientNames.count{
                    if food.nutrients[i].nutrientName == nutrientNames[j]{
                        var dict = [String:String]()
                        
                        for measurement in food.nutrients[i].measurements{
                            dict[measurement.valueForKey("key") as! String] = measurement.valueForKey("value") as? String
                            if measurement.valueForKey("key") as! String == food.servingSize{
                                sum[j] += Float(measurement.valueForKey("value") as! String)!*food.numberOfServings
                                //print(measurement.valueForKey("value") as? String)
                            }
                        }
                        measurementsDictionary.append(dict)
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
        case .Lunch:
            summary = lunchSummary
        case .Dinner:
            summary = dinnerSummary
        case .Snack:
            summary = breakfastSummary
        case .Total:
            for i in 0..<summary.count{
                summary[i] = breakfastSummary[i] + lunchSummary[i] + dinnerSummary[i]
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

    // MARK: Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return nutrientNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell")! as! SummaryCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.titleLabel.text = nutrientNames[indexPath.row]
        cell.valueLabel.text = "\(summary[indexPath.row]) " + nutrientUnits[indexPath.row]
        
        return cell
    }
}
