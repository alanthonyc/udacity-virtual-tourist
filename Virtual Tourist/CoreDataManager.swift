//
//  CoreDataManager.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 1/26/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILENAME = "Virtual_Tourist.sqlite"

class CoreDataManager {
    
    class func sharedInstance() -> CoreDataManager {
        struct Static {
            static let instance = CoreDataManager()
        }
        return Static.instance
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        print("dir")
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        
    } ()

    lazy var managedObjectModel: NSManagedObjectModel = {
        print("momd")
        let modelURL = NSBundle.mainBundle().URLForResource("Virtual_Tourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        
    } ()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        print("psc")
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILENAME)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // TODO:
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
            // // //
        }
        return coordinator
        
    } ()

    lazy var managedObjectContext: NSManagedObjectContext = {
        print("moc")
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext

    } ()

    // MARK: - Core Data Saving Support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                
                // TODO:
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
                // // //
            }
        }
    }
}