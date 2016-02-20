//
//  Photo.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/16/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let ENTITY_NAME_PHOTO = "Photo"

class Photo: NSManagedObject
{
    struct Keys
    {
        static let fileSystemUrl = "fileSystemUrl"
        static let filename = "filename"
        static let flickrUrl = "flickrUrl"
        static let Pin = "pin"
        static let flickrId = "flickrId"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext)
    {
        let entity =  NSEntityDescription.entityForName(ENTITY_NAME_PHOTO, inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        fileSystemUrl = dictionary[Keys.fileSystemUrl] as? String
        filename = dictionary[Keys.filename] as? String
        flickrUrl = dictionary[Keys.flickrUrl] as? String
        flickrId = dictionary[Keys.flickrId] as? String
        pin = dictionary[Keys.Pin] as? Pin
    }
    
    func image() -> UIImage?
    {
        if self.fileSystemUrl != nil && self.fileSystemUrl != "" {
            var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            documentsPath.appendContentsOf("/\(self.filename!)")
            let data = NSData(contentsOfFile: documentsPath)
            if data != nil {
                return UIImage(data: data!)
            }
            
        } else if self.flickrUrl != nil && self.flickrUrl != "" {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                if let imageData = NSData(contentsOfURL: NSURL(string: self.flickrUrl!)!) {
                    let path = pathForIdentifier(self.flickrId!)
                    let image = UIImage(data: imageData)!
                    let data = UIImagePNGRepresentation(image)!
                    self.fileSystemUrl = path
                    data.writeToFile(path, atomically: true)
                }
            })
            return nil
        }
        return nil
    }
    
    override func prepareForDeletion()
    {
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        documentsPath.appendContentsOf("/\(self.filename!)")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(documentsPath)
        } catch _ as NSError {
            print("Error deleting image file at: \(documentsPath)")
        }
    }
}
