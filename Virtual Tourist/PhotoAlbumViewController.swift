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
        let span = MKCoordinateSpanMake(mapView.region.span.longitudeDelta / 200, mapView.region.span.latitudeDelta / 200)
        let region = MKCoordinateRegionMake(self.coordinates, span)
        mapView.setCenterCoordinate(self.coordinates, animated: true)
        mapView.setRegion(region, animated: true)
        let p = FlickrRequestController()
        p.getImagesAroundLocation(self.coordinates.latitude, lon:self.coordinates.longitude, page:1)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
