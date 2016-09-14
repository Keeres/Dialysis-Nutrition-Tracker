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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        summaryTable.delegate = self
        summaryTable.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        breakfast.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("AddBreakfastCell")! as! AddBreakfastCell

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        <#code#>
    }
}
