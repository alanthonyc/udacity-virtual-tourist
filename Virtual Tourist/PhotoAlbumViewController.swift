//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/13/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {

    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    
    // MARK: - Housekeeping

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.coordinates = CLLocationCoordinate2DMake(0, 0)
    }
    
    override func viewDidAppear(animated: Bool)
    {
//        let span = MKCoordinateSpanMake(mapView.region.span.longitudeDelta / 200, mapView.region.span.latitudeDelta / 200)
//        let region = MKCoordinateRegionMake(self.coordinates, span)
        let region = MKCoordinateRegionMakeWithDistance(self.coordinates, 2000, 2000);
        mapView.setCenterCoordinate(self.coordinates, animated: true)
        mapView.setRegion(region, animated: true)
        let p = FlickrRequestController()
        p.getImagesAroundLocation(self.coordinates.latitude, lon:self.coordinates.longitude, page:1) {
            JSONResult, error in
            if let error = error {
                //error handling
                print("Error: \(error)")
                
            } else {
                // success
                // i.e. update view controller here, e.g. from favorite actors:
//                if let moviesDictionaries = JSONResult.valueForKey("cast") as? [[String : AnyObject]] {
//                    
//                    // Parse the array of movies dictionaries
//                    _ = moviesDictionaries.map() { (dictionary: [String : AnyObject]) -> Movie in
//                        let movie = Movie(dictionary: dictionary, context: self.sharedContext)
//                        
//                        movie.actor = self.actor
//                        
//                        return movie
//                    }
//                    
//                    // Update the table on the main thread
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.tableView.reloadData()
//                    }
//                    
//                    // Save the context
//                    self.saveContext()
                
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
