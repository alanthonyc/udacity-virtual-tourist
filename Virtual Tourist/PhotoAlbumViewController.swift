//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/13/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseId = "CollectionViewCell"

let NUMBER_OF_SECTIONS = 1
let MAX_NUMBER_OF_CELLS = 21
let PHOTO_ALBUM_VC_IDENTIFIER = "photoAlbumViewController"

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: - Properties
    
    var pin: Pin?
    var maxPage: Int!
    var currentPage: Int!
    var insertedPhotos: [NSIndexPath]!
    var deletedPhotos: [NSIndexPath]!
    var updatedPhotos: [NSIndexPath]!
    
    // MARK: - Housekeeping

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func viewDidLoad()
    {
        configureCollectionView()
        configureMapAnnotation()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            print("Error performing fetch.")
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if self.pin!.photosForPage != nil {
            if self.pin!.photosForPage! == 0 {
                self.collectionView.alpha = 0.0
                self.newCollectionButton.enabled = false
            }
        }
        let (downloaded, notDownloaded) = photosDownloaded()
        print("Downloaded: \(downloaded!.count)")
        print("Not downloaded: \(notDownloaded!.count)")
        if notDownloaded!.count > 0 || self.pin!.photosForPage == nil
        {
            let qos = QOS_CLASS_BACKGROUND
            let backgroundQ = dispatch_get_global_queue(qos, 0)
            dispatch_async(backgroundQ, { () -> Void in
                self.downloadRemainingPhotos(notDownloaded!)
            })
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        let coordinates = CLLocationCoordinate2DMake(self.pin!.latitude as! Double, self.pin!.longitude as! Double)
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 1600, 1600);
        mapView.setCenterCoordinate(coordinates, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: --- View Configuration
    
    func configureCollectionView()
    {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.maxPage = 1
        self.currentPage = 1
    }
    
    func configureMapAnnotation()
    {
        let point = MKPointAnnotation.init()
        point.coordinate = CLLocationCoordinate2DMake(self.pin!.latitude as! Double, self.pin!.longitude as! Double)
        self.mapView.addAnnotation(point)
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionButtonTapped()
    {
        downloadNextAlbum()
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var frc: NSFetchedResultsController =
    {
        let request = NSFetchRequest(entityName: ENTITY_NAME_PHOTO)
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        request.sortDescriptors = []
        request.fetchBatchSize = MAX_NUMBER_OF_CELLS
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    } ()
    
    // MARK: - View Controller Actions
    
    // MARK: --- Photo Album Subsets
    
    func photosDownloaded() -> ([Photo]?, [Photo]?)
    {
        var downloaded: [Photo] = []
        var notDownloaded: [Photo] = []
        print("Checking \(self.pin!.photos!.count) photos if downloaded:")
        for photo in self.pin!.photos!
        {
            print("---> \((photo as! Photo).filename!) ::: \((photo as! Photo).downloaded)")
            if (photo as! Photo).downloaded != nil && (photo as! Photo).downloaded! == true
            {
                print(">>downloaded<<")
                downloaded.append(photo as! Photo)
                
            } else {
                print(">>not yet downloaded<<")
                notDownloaded.append(photo as! Photo)
            }
        }
        print("\(downloaded.count) downloaded, \(notDownloaded.count) not yet downloaded")
        return (downloaded, notDownloaded)
    }
    
    // MARK: --- Photo Actions
    
    func downloadRemainingPhotos(photos: [Photo])
    {
        for photo in photos
        {
            self.pin!.downloadPhoto(photo)
        }
    }
    
    // MARK: --- Photo Album Actions
    
    func downloadAlbum(page: Int)
    {
        self.pin!.page = page
        self.pin!.getImages()
    }
    
    func downloadNextAlbum()
    {
        deletePhotoAlbum()
        var nextPage = (self.pin!.page as! Int) + 1
        if nextPage > self.pin!.pages as! Int {
            nextPage = 1
        }
        downloadAlbum(nextPage)
    }
    
    func deletePhotoAlbum()
    {
        for item in 0 ... self.frc.fetchedObjects!.count
        {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell?
            if cell != nil {
                cell!.imageCell.image = nil
            }
        }
        for photo in self.pin!.photos!
        {
            self.moc.deleteObject(photo as! Photo)
        }
        saveMoc()
    }
    
    // MARK: - Core Data Helper
    
    lazy var moc =
    {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    func saveMoc()
    {
        dispatch_async(dispatch_get_main_queue())
            {
                () -> Void in
                do {
                    try self.moc.save()
                    
                } catch let error as NSError {
                    print("error saving moc: \(error)")
                }
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return NUMBER_OF_SECTIONS
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let itemCount = self.frc.fetchedObjects!.count
        if itemCount > 0 {
            return itemCount
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell;
    }
    
    func configureCell(cell: CollectionViewCell, indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        cell.layer.cornerRadius = 4.0
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.alpha = 1.0
        cell.imageCell.layer.shadowOpacity = 0.5
        cell.imageCell.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cell.imageCell.layer.shadowOffset = CGSizeMake(-2, 2)

        let photo = self.frc.objectAtIndexPath(indexPath) as! Photo
        let image = photo.image() as UIImage?
        if image != nil {
            cell.imageCell.image = image
            cell.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let photoToDelete = frc.objectAtIndexPath(indexPath) as! Photo
        self.pin!.photosForPage = (self.pin!.photosForPage as! Int) - 1
        self.moc.deleteObject(photoToDelete)
        saveMoc()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        insertedPhotos = [NSIndexPath]()
        deletedPhotos = [NSIndexPath]()
        updatedPhotos = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        collectionView.performBatchUpdates({() -> Void in
            
            for photo in self.insertedPhotos
            {
                self.collectionView.insertItemsAtIndexPaths([photo])
            }
            
            for indexPath in self.deletedPhotos
            {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }

            for photo in self.updatedPhotos
            {
                self.collectionView.reloadItemsAtIndexPaths([photo])
            }
            
            }, completion: nil)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch type{
            case .Insert:
                self.insertedPhotos.append(newIndexPath!)
                break
            case .Delete:
                self.deletedPhotos.append(indexPath!)
                break
            case .Update:
                self.updatedPhotos.append(indexPath!)
                break
            default:
                break
        }
    }
}
















