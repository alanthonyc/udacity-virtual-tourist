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

class ViewController: UIViewController, MKMapViewDelegate {

    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action:"mapLongPress:")
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
        self.mapView.delegate = self;
        let pins = fetchAllPins()
        addPinsFromDataStore(pins)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: Core Data
    
    lazy var moc = {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    func saveMoc() {
        do {
            try moc.save()
        
        } catch let error as NSError {
            print("error saving moc: \(error)")
        }
    }
    
    lazy var scratchContext: NSManagedObjectContext = {
        
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataManager.sharedInstance().persistentStoreCoordinator
        return context
        
    } ()
    
    func fetchAllPins() -> [Pin] {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try moc.executeFetchRequest(fetchRequest) as! [Pin]
            
        } catch let error as NSError {
            print("Error fetching pins: \(error)")
            return [Pin]()
        }
    }
    
    // MARK: - Map View
    
    func addPinsFromDataStore(pins: [Pin]) {
        for pin in pins {
            let point = MKPointAnnotation.init()
            point.coordinate = CLLocationCoordinate2DMake(pin.latitude as! Double, pin.longitude as! Double)
            self.mapView.addAnnotation(point)
        }
    }
    
    func mapLongPress (sender:UILongPressGestureRecognizer) -> Void
    {
        if (sender.state == .Began) {
            let location = sender.locationInView(self.mapView)
            self.coordinates = mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            print("Coordinates: \(self.coordinates.longitude) / \(self.coordinates.latitude)")
        }
        
        if (sender.state == .Ended) {
            let point = MKPointAnnotation.init()
            point.coordinate = self.coordinates
            self.mapView.addAnnotation(point)
            self.createPinEntity(point.coordinate)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        let photoAlbumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoAlbumViewController") as! PhotoAlbumViewController?
        mapView.deselectAnnotation(view.annotation, animated: false)
        photoAlbumViewController?.coordinates.longitude = (view.annotation?.coordinate.longitude)!
        photoAlbumViewController?.coordinates.latitude = (view.annotation?.coordinate.latitude)!
        self.navigationController?.pushViewController(photoAlbumViewController!, animated: true)
    }
    
    func createPinEntity(location: CLLocationCoordinate2D)
    {
        let pinEntity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: moc)
        let photoEntity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: moc)
        let pin = NSManagedObject(entity: pinEntity!, insertIntoManagedObjectContext: moc)
        let photo = NSManagedObject(entity: photoEntity!, insertIntoManagedObjectContext: moc)
        photo.setValue("test://this_is_a_test_url", forKey: "url")
        photo.setValue(pin, forKey: "pin")
        pin.setValue(location.longitude, forKey: "longitude")
        pin.setValue(location.latitude, forKey: "latitude")
        saveMoc()
    }
}

