//
//  ServingSizePickerTable.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/12/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class ServingSizeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    var servingSizes = [String]()
    var servingSize : String?
    var checked = [Bool]() // Have an array equal to the number of cells in your table
    let cellSize = 44
    var initialTable:Bool?
    weak var delegate: DetailedViewController!
    weak var editDelegate: EditEntryViewController!
    var delegateInUse : Int?
    
    @IBOutlet weak var servingSizeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.servingSizeTable.delegate = self
        self.servingSizeTable.dataSource = self
        initialTable = true
      }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = self.servingSizeTable.frame
        frame.origin.y += self.servingSizeTable.frame.height
        self.servingSizeTable.frame = frame
        
        self.servingSizeTable.layoutMargins = UIEdgeInsetsZero
        self.servingSizeTable.separatorInset  = UIEdgeInsetsZero
    }
    
    override func viewDidAppear(animated: Bool) {
        
        UIView.animateWithDuration(1, animations: {
            var frame = self.servingSizeTable.frame
            frame.origin.y -= CGFloat((self.servingSizes.count+1)*self.cellSize)//self.servingSizeTable.frame.height
            self.servingSizeTable.frame = frame
        })
    }
    
    func dismissView(){
        UIView.animateWithDuration(1, animations: {
            var frame = self.servingSizeTable.frame
            frame.origin.y += CGFloat((self.servingSizes.count+1)*self.cellSize)//self.servingSizeTable.frame.height
            self.servingSizeTable.frame = frame
        })
        
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {

            self.dismissViewControllerAnimated(false, completion: nil)
            if self.delegateInUse == 0{
                NSNotificationCenter.defaultCenter().postNotificationName("updateTable", object: nil)
            }else if self.delegateInUse == 1{
                NSNotificationCenter.defaultCenter().postNotificationName("reloadTable", object: nil)
            }
            

        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if(touch.view!.tag != 5 ){
                dismissView()
            }
        }
    }
    
    // MARK: Table Delegate Functions
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCellWithIdentifier("HeaderCell")! as UITableViewCell

        return headerView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(cellSize)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
     
        for _ in 0 ... servingSizes.count{
            checked.append(false)
        }
        
        return servingSizes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell")! as UITableViewCell
        cell.textLabel?.text = servingSizes[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.layoutMargins = UIEdgeInsetsZero

        if initialTable == true && cell.textLabel!.text == servingSize{
            cell.accessoryType = .Checkmark
            initialTable = false
        }else if !checked[indexPath.row] {
            cell.accessoryType = .None
        } else if checked[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
   
            resetChecks()
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            } else {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
            self.servingSize = cell.textLabel?.text
            
            if delegateInUse == 0{
                delegate.updatedServingSize(self.servingSize!)
            }else if delegateInUse == 1{
                editDelegate.entryUpdatedServingSize(self.servingSize!)
            }
            
            dismissView()
        }
    }
    
    func resetChecks() {
        for i in 0 ..< servingSizeTable.numberOfSections {
            for j in 0 ..< servingSizeTable.numberOfRowsInSection(i) {
                if let cell = servingSizeTable.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    cell.accessoryType = .None
                }
            }
        }
    }
    
    
    // Buttons
    @IBAction func cancelButton(sender: AnyObject) {
        dismissView()
    }
    
    @IBAction func checkButton(sender: AnyObject) {
        dismissView()
    }
}
