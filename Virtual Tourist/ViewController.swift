//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 1/17/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    lazy var moc = {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    lazy var scratchContext: NSManagedObjectContext = {
        
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataManager.sharedInstance().persistentStoreCoordinator
        return context
        
    } ()
}

    