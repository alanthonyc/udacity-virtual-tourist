//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 1/17/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import CoreData
import MapKit

let DEFAULT_PIN_COLLECTION_NAME = "DefaultPinCollection"
let DEFAULT_PIN_CATEGORY_NAME = "DefaultPinCategory"

class DraggableAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func coordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.coordinate = newCoordinate
        didChangeValueForKey("coordinate")
    }
}

class ViewController: UIViewController, MKMapViewDelegate
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    var pinDictionary: [MKPointAnnotation: Pin]!
    var pinCollection: Collection!
    var pinCategory: Category!
    var draggableAnnotation: DraggableAnnotation!
    
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action:"mapLongPress:")
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
        self.mapView.delegate = self;
        self.pinCollection = self.defaultCollection()
        self.pinCategory = self.defaultCategory()
        self.pinDictionary = [MKPointAnnotation: Pin]()
        let pins = fetchAllPins()
        addPinsFromDataStore(pins)

    }
    
    override func viewWillDisappear(animated: Bool)
    {
        saveMoc()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: Core Data
    
    lazy var moc =
    {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    func saveMoc()
    {
        do {
            try moc.save()
        
        } catch let error as NSError {
            print("error saving moc: \(error)")
        }
    }
    
    lazy var scratchContext: NSManagedObjectContext =
    {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataManager.sharedInstance().persistentStoreCoordinator
        return context
        
    } ()
    
    func defaultCollection() -> Collection?
    {
        let request = NSFetchRequest(entityName: ENTITY_NAME_COLLECTION)
        request.predicate = NSPredicate(format: "name == %@", DEFAULT_PIN_COLLECTION_NAME)
        request.fetchLimit = 1
        request.sortDescriptors = []
        do {
            let result = try self.moc.executeFetchRequest(request) as NSArray
            if result.count == 1 {
                return (result.firstObject as! Collection)
                
            } else {
                let collectionEntity = NSEntityDescription.entityForName(ENTITY_NAME_COLLECTION, inManagedObjectContext: self.moc)
                let collection = NSManagedObject(entity: collectionEntity!, insertIntoManagedObjectContext: self.moc)
                collection.setValue(DEFAULT_PIN_COLLECTION_NAME, forKey: Collection.Keys.Name)
                self.saveMoc()
                return (collection as! Collection)
            }
        } catch let error as NSError {
            print("Error fetching default pin collection: \(error)")
            return nil
        }
    }
    
    func defaultCategory() -> Category?
    {
        let request = NSFetchRequest(entityName: ENTITY_NAME_CATEGORY)
        request.predicate = NSPredicate(format: "name == %@", DEFAULT_PIN_CATEGORY_NAME)
        request.fetchLimit = 1
        request.sortDescriptors = []
        do {
            let result = try self.moc.executeFetchRequest(request) as NSArray
            if result.count == 1 {
                return (result.firstObject as! Category)
                
            } else {
                let categoryEntity = NSEntityDescription.entityForName(ENTITY_NAME_CATEGORY, inManagedObjectContext: self.moc)
                let category = NSManagedObject(entity: categoryEntity!, insertIntoManagedObjectContext: self.moc)
                category.setValue(DEFAULT_PIN_CATEGORY_NAME, forKey: Category.Keys.Name)
                self.saveMoc()
                return (category as! Category)
            }
        } catch let error as NSError {
            print("Error fetching default pin category: \(error)")
            return nil
        }
    }
    
    func fetchAllPins() -> [Pin]
    {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try moc.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            print("Error fetching pins: \(error)")
            return [Pin]()
        }
    }
    
    // MARK: - Map View
    
    func addPinsFromDataStore(pins: [Pin])
    {
        for pin in pins {
            let point = MKPointAnnotation.init()
            point.coordinate = CLLocationCoordinate2DMake(pin.latitude as! Double, pin.longitude as! Double)
            self.mapView.addAnnotation(point)
            self.pinDictionary[point] = pin
            if (pin.collection == nil) {
                pin.setValue(self.pinCollection, forKey: Pin.Keys.Collection)
            }
            if (pin.category == nil) {
                pin.setValue(self.pinCategory, forKey: Pin.Keys.Category)
            }
        }
    }
    
    func mapLongPress (sender:UILongPressGestureRecognizer) -> Void
    {
        let location = sender.locationInView(self.mapView)
        if (sender.state == .Began)
        {
            self.coordinates = mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            self.draggableAnnotation = DraggableAnnotation.init(coordinate:self.coordinates)
            self.mapView.addAnnotation(self.draggableAnnotation)
        }
        
        if (sender.state == .Changed)
        {
            self.coordinates = mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            if self.draggableAnnotation != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.draggableAnnotation.coordinate(self.coordinates)
                })
            }
        }
        
        if (sender.state == .Ended)
        {
            self.mapView.removeAnnotation(self.draggableAnnotation)
            self.coordinates = mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            let pinAnnotation = MKPointAnnotation.init()
            pinAnnotation.coordinate = self.coordinates
            self.mapView.addAnnotation(pinAnnotation)
            self.pinDictionary[pinAnnotation] = self.createPinEntity(self.coordinates)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        let photoAlbumViewController = self.storyboard?.instantiateViewControllerWithIdentifier(PHOTO_ALBUM_VC_IDENTIFIER) as! PhotoAlbumViewController?
        mapView.deselectAnnotation(view.annotation, animated: false)
        photoAlbumViewController?.pin = pinDictionary[view.annotation as! MKPointAnnotation]
        self.navigationController?.pushViewController(photoAlbumViewController!, animated: true)
    }
    
    func createPinEntity(location: CLLocationCoordinate2D) -> Pin
    {
        let pinEntity = NSEntityDescription.entityForName(ENTITY_NAME_PIN, inManagedObjectContext: moc)
        let pin = NSManagedObject(entity: pinEntity!, insertIntoManagedObjectContext: moc)
        pin.setValue(location.longitude, forKey: Pin.Keys.Longitude)
        pin.setValue(location.latitude, forKey: Pin.Keys.Latitude)
        pin.setValue(self.pinCollection, forKey: Pin.Keys.Collection)
        pin.setValue(self.pinCategory, forKey: Pin.Keys.Category)
        pin.setValue(nil, forKey: Pin.Keys.PhotosForPage)
        pin.setValue(1, forKey: Pin.Keys.Page)
        (pin as! Pin).getImages()
        saveMoc()
        return pin as! Pin
    }
}

// MARK: - Helper

func pathForIdentifier(identifier: String) -> String
{
    let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
    
    return fullURL.path!
}








