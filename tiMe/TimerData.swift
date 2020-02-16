//
//  TimerData.swift
//  tiMe
//
//  Created by Anna Bibyk on 16.02.2020.
//  Copyright © 2020 Anna Bibyk. All rights reserved.
//

import UIKit
import CoreData

class TimeData {
    
    //MARK: - Fetching data
    
    public static func fetchTimerListData(timeList: inout [NSManagedObject]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimerListData")
        
        do {
            timeList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. Error : \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Saving the time into list
    
    public static func saveNewTimeInList(timeList: inout [NSManagedObject], noteToTime: String, timer: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TimerListData", in: managedContext)!
        let time = NSManagedObject(entity: entity, insertInto: managedContext)
        let message = noteToTime == "" ? "Time \(timeList.count + 1)" : noteToTime
        
        time.setValue(timer, forKeyPath: "time")
        time.setValue(message, forKey: "message")
        
        do {
            try managedContext.save()
            timeList.append(time)
        } catch let error as NSError {
            print("Could not save. Error : \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Clearing the list
    
    public static func clearTimeListData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimerListData")
        
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results {
                if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                    managedContext.delete(managedObjectData)
                }
            }
            try managedContext.save()
            print("All the elements deleted")
        } catch let error as NSError {
            print("Could not delete. Error : \(error) \(error.userInfo)")
        }
    }
    
}
