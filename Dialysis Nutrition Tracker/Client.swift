//
//  Client.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/1/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation

class Client : NSObject{

    let APISearchURL = "http://api.nal.usda.gov/ndb/search/"
    let APIReportURL = "http://api.nal.usda.gov/ndb/reports/"

    
    func searchFoodItemsUSDADatabase(searchString:String, completionHandler: (foodItemsArray:[[String:AnyObject]]?, error: String?) -> Void) {

        let methodParameters: [String: AnyObject] = [
            "api_key":          "HVBePg5RGhFz8twmpGD2t2BZx7pW6XiTTNpNWwj2",
            "format":           "json",                     // result format
            "q"     :           searchString,               // Terms requested and used in the search
            "sort"  :           "r",                        // Sort the results by food name(n) or by search relevance(r)
            "max"   :           "75",                        // Maximum rows to return
            "offset":           "0"                         // Beginning row in the result set to begin
        ]
        
        
        let session = NSURLSession.sharedSession()
        let urlString = APISearchURL + escapedParameters(methodParameters)
        

        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        print(request)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandler(foodItemsArray: nil, error: error)
                return
            }
            if error == nil{
                let parsedResult: AnyObject!
                
                if let data = data {
                    do {
                        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        
                    } catch {
                        displayError("Could not parse the data as JSON: '\(data)'")
                        return
                    }

                    guard let list = parsedResult["list"] as? [String: AnyObject] else {
                        print("food list not found")
                        completionHandler(foodItemsArray: nil, error: "Search returns zero results")

                        return
                    }
              
                    guard let foodItems = list["item"] as? [[String:AnyObject]] else {
                        print("food items not found")
                        return
                    }
                    
                    completionHandler(foodItemsArray: foodItems, error: nil)
                }
            }
        }
    task.resume();
    }
    
    func getFoodNutrientUSDADatabase(ndbno:String, completionHandler: (foodName:String, ndbno:String, nutritionsArray:[[String:AnyObject]]?, error: String?) -> Void) {
        let methodParameters: [String: AnyObject] = [
            "api_key":          "HVBePg5RGhFz8twmpGD2t2BZx7pW6XiTTNpNWwj2",
            "ndbno":            ndbno,                          // NDB no
            "type":             "b",                             // Report type: [b]asic, [f]ull, [s]tats
            "format":          "json"                          // report formt: xml or json
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = APIReportURL + escapedParameters(methodParameters)
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        print(request)
    
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandler(foodName: " ", ndbno:" ", nutritionsArray: nil, error: error)
                return
            }
            if error == nil{
                let parsedResult: AnyObject!
                
                if let data = data {
                    do {
                        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        
                    } catch {
                        displayError("Could not parse the data as JSON: '\(data)'")
                        return
                    }
                  //  print(parsedResult)
                    guard let report = parsedResult["report"] as? [String: AnyObject] else {
                        print("nutrient report not found")
                        completionHandler(foodName: " ", ndbno:" ", nutritionsArray: nil, error: "No report found")
                        
                        return
                    }
                    
                    guard let food = report["food"] as? [String:AnyObject] else {
                        print("error retriving food")
                        return
                    }
                    
                    guard let foodName = food["name"] as? String else {
                        print("error retriving food name")
                        return
                    }
                    
                    guard let ndbno = food["ndbno"] as? String else {
                        print("error retriving food name")
                        return
                    }
                    print(ndbno)

                    guard let nutrients = food["nutrients"] as? [[String:AnyObject]] else {
                        print("error retriving nutrients")
                        return
                    }

                    completionHandler(foodName:foodName, ndbno:ndbno, nutritionsArray: nutrients, error: nil)
                }
            }
        
        }
        task.resume();
    }
    
    
    private func escapedParameters(parameters: [String: AnyObject]) -> String{ // input named parameter of type dictionary, returns type string
        
        if parameters.isEmpty{
            return " "
        }else{
            var keyValuePairs = [String]()
            
            for (key, value) in parameters{
                // make sure it's a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
}
