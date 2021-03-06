//
//  Category+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/21/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category
{
    @NSManaged var name: String?
    @NSManaged var pins: NSSet?
}
