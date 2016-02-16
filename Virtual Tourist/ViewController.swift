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
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: Core Data
    
    lazy var moc = {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    lazy var scratchContext: NSManagedObjectContext = {
        
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = CoreDataManager.sharedInstance().persistentStoreCoordinator
        return context
        
    } ()
    
    // MARK: - Map View
    
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
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        let photoAlbumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoAlbumViewController") as! PhotoAlbumViewController?
        mapView.deselectAnnotation(view.annotation, animated: false)
        self.createPinEntity((view.annotation?.coordinate)!)
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
        
        do {
            try moc.save()
            
        } catch let error as NSError {
            print("error saving moc for pin: \(error)")
        }
    }
}

