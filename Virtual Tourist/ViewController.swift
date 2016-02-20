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

class ViewController: UIViewController, MKMapViewDelegate
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    var pinDictionary: [MKPointAnnotation: Pin]!
    
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action:"mapLongPress:")
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
        self.mapView.delegate = self;
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
        }
    }
    
    func mapLongPress (sender:UILongPressGestureRecognizer) -> Void
    {
        if (sender.state == .Began) {
            let location = sender.locationInView(self.mapView)
            self.coordinates = mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        }
        if (sender.state == .Ended) {
            let point = MKPointAnnotation.init()
            point.coordinate = self.coordinates
            self.mapView.addAnnotation(point)
            self.pinDictionary[point] = self.createPinEntity(point.coordinate)
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
        pin.setValue(1, forKey: Pin.Keys.Page)
        FlickrRequestController().getImagesAroundLocation(location.latitude, lon:location.longitude, page:1, picsPerPage: MAX_NUMBER_OF_CELLS) {
            JSONResult, error in
            if let error = error {
                print("Error pre-loading images for pin: \(error)")
                
            } else {
                let photosDictionary = JSONResult
                print("Photos Dict: \(photosDictionary)")
                let photos = photosDictionary["photo"] as! NSArray
                for pic in photos { (pin as! Pin).attachPhoto(pic as! NSDictionary, moc: self.moc) }
            }
        }
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








