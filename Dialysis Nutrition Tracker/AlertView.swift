//
//  AlertView.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 9/18/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class AlertView: NSObject {
    class func displayError(view:UIViewController, title:String, error:String){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            view.presentViewController(alert, animated: true, completion: nil)
        })
    }
}