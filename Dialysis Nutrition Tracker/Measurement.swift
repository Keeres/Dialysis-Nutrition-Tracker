//
//  Measurement.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/7/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class Measurement: NSManagedObject {
    
    @NSManaged var key:String
    @NSManaged var value:String
    @NSManaged var nutrient:Nutrient
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(key:String, value:String, context:NSManagedObjectContext){
        if let entity =  NSEntityDescription.entityForName("Measurement", inManagedObjectContext: context){
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.key = key
            self.value = value
            
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}
