//
//  Nutrient.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 8/6/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class Nutrient:NSManagedObject{
    
    @NSManaged var nutrientName:String
    @NSManaged var unit:String
    @NSManaged var food:Food?
    @NSManaged var measurements:[Measurement]
 
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(nutrientName:String, unit:String, context:NSManagedObjectContext){
        if let entity =  NSEntityDescription.entityForName("Nutrient", inManagedObjectContext: context){
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.nutrientName = nutrientName
            self.unit = unit
            
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}
