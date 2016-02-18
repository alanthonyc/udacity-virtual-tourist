//
//  PhotosAPI.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/16/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//   - adapted from "Sleeping in the Library" by Udacity
//

import Foundation

let API_KEY = "3a521be533d5763d391a30d272ed398e"
let METHOD_SEARCH = "flickr.photos.search"
let BASE_URL = "https://api.flickr.com/services/rest/"
let DEFAULT_PICS_PER_PAGE = 21

class FlickrRequestController: NSObject
{
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    func getImagesAroundLocation(lat: Double, lon: Double, page: Int, completionHandler: CompletionHander) {
        
        let latString = "\(lat)"
        let lonString = "\(lon)"
        let pageString = "\(page)"
        let picsPerPageString = "\(DEFAULT_PICS_PER_PAGE)"
        let methodArguments = [
            "method": METHOD_SEARCH,
            "api_key": API_KEY,
            "content_type": "1",
            "lat": latString,
            "lon": lonString,
            "radius": "1",
            "format": "json",
            "extras": "url_m",
            "per_page": picsPerPageString,
            "media": "photos",
            "page": pageString,
            "nojsoncallback": "1"
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary,
                _ = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find keys 'photos' and 'photo' in \(parsedResult)")
                    return
            }
            
            guard let _ = photosDictionary["pages"] as? Int else {
                print("Cannot find key 'pages' in \(photosDictionary)")
                return
            }
            
            completionHandler(result: photosDictionary, error: error)
        }
        task.resume()
    }
    
    func getImage(photoUrl: String, completionHandler: CompletionHander)
    {
        let session = NSURLSession.sharedSession()
        let urlString = photoUrl
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            if let imageData = NSData(contentsOfURL: url) {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(result: imageData, error: error)
                })
            } else {
                print("Image does not exist at \(url)")
            }
        }
        task.resume()
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String
    {
        var urlVars = [String]()
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}