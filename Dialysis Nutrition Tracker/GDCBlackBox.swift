//
//  GDCBlackBox.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/1/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}