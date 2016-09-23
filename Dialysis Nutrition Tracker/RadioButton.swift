//
//  RadioButton.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 9/23/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//
import UIKit

class RadioButton: UIButton {
    // Images
    let buttonDownImage = UIImage(named: "Button Down")!
    let buttonUpImage = UIImage(named: "Button")!
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(buttonDownImage, forState: .Normal)
            } else {
                self.setImage(buttonUpImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(RadioButton.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
