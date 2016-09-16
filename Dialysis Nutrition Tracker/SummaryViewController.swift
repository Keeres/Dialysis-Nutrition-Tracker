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
    var nutrientList : [[String]] = [[],[]]
    var count = 0
    var measurementsDictionary = [[String:String]]()
    enum ButtonType: Int { case Breakfast = 0, Lunch, Dinner, Snack, Total}

    override func viewDidLoad() {
        super.viewDidLoad()

        summaryTable.delegate = self
        summaryTable.dataSource = self
        buttons = [breakfastButton, lunchButton, dinnerButton, snackButton, totalButton]
        buttonSetup()
        print(nutrientList.count)

        summary = [Float](count: nutrientList.count, repeatedValue: 0.0 )
    //    print(summary.count)
        breakfastSummary = summaryCalc(breakfast)
        lunchSummary = summaryCalc(lunch)
        dinnerSummary = summaryCalc(dinner)
        foodCount(ButtonType.Total.rawValue)
    }
    
    
    func summaryCalc(meal:[Food]) -> [Float]{
        
        for food in meal{
            print(food.name)
            
            // for nutrient in food.nutrients{
            for i in 0..<food.nutrients.count{
                for j in 0..<nutrientList.count{
                    if food.nutrients[i].nutrientName == nutrientList[j][0]{
                        print(food.nutrients[i].nutrientName)
                        var dict = [String:String]()
                        
                        //   print(nutrient.measurements.count)
                        for measurement in food.nutrients[i].measurements{
                            dict[measurement.valueForKey("key") as! String] = measurement.valueForKey("value") as? String
                            
                            if measurement.valueForKey("key") as! String == food.servingSize{
                                
                                summary[i] += Float(measurement.valueForKey("value") as! String)!
                                print(measurement.valueForKey("value") as? String)
                            }
                        }
                        measurementsDictionary.append(dict)
                        
                    }
                    
                }
                
            }
        }
        return summary
    }
    
        
    func buttonSetup(){
        for i in 0..<buttons.count{
            buttons[i].layer.borderWidth = 0.5
            buttons[i].layer.borderColor = UIColor.grayColor().CGColor
            buttons[i].backgroundColor = UIColor.clearColor()
        }
    }
    
    @IBAction func mealButton(sender: AnyObject) {
        for i in 0..<buttons.count{
            if i == sender.tag{
                buttons[i].backgroundColor = UIColor.orangeColor()
            }else{
                buttons[i].backgroundColor = UIColor.clearColor()
            }
        }
        foodCount(sender.tag)
        dispatch_async(dispatch_get_main_queue()) {
            self.summaryTable.reloadData()
        }
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
    
    func test(){
        for i in 0..<breakfastSummary.count{
            print(breakfastSummary[i])
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return nutrientList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell")! as! SummaryCell
        cell.titleLabel.text = nutrientList[indexPath.row][0]
        cell.valueLabel.text = "\(summary[indexPath.row]) " + nutrientList[indexPath.row][1]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
