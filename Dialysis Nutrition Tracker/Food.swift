//
//  Food.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/6/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit
import CoreData

class Food:NSManagedObject {
    @NSManaged var name : String
    @NSManaged var ndbno : String
    @NSManaged var mealType : String
    @NSManaged var servingSize: String
    @NSManaged var numberOfServings: Float
    @NSManaged var date:String
    @NSManaged var index:Int
    @NSManaged var nutrients : [Nutrient]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name:String, ndbno:String, mealType:String, index:Int, numberOfServings:Float, date:String, context:NSManagedObjectContext){
        if let entity =  NSEntityDescription.entityForName("Food", inManagedObjectContext: context){
             super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.name = name
            self.ndbno = ndbno
            self.mealType = mealType
            self.index = index
            self.numberOfServings = numberOfServings
            self.date = date
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}