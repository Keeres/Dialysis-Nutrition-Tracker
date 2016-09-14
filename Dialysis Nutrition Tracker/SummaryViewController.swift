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
    
    var breakfast = [Food]()
    var lunch = [Food]()
    var dinner = [Food]()
    var breakfastSummary = [Float]()
    
    var measurementsDictionary = [[String:String]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        summaryTable.delegate = self
        summaryTable.dataSource = self
        
        breakfastSummary = summaryCalc(breakfast)
        test()
    }
    
    
    func summaryCalc(meal:[Food]) -> [Float]{
        var summary = [Float](count: meal[0].nutrients.count, repeatedValue: 0.0 )

        for food in meal{
            print(food.name)
            
           // for nutrient in food.nutrients{
            for i in 0..<food.nutrients.count{
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
        return summary
    }
    
    func test(){
        for i in 0..<breakfastSummary.count{
            print(breakfastSummary[i])
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return breakfast.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
       // let cell = tableView.dequeueReusableCellWithIdentifier("AddBreakfastCell")! as! AddBreakfastCell
let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
