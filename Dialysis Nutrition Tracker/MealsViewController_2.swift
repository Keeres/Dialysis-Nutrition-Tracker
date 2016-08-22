//
//  MealsViewController_2.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/4/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class MealsViewController_2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("BreakfastCell")! as UITableViewCell
        
        return cell
    }
}
