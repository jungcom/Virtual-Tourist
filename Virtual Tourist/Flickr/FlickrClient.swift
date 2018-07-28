//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

class FlickrClient : NSObject{
    
    var latitude:Double?
    var longitude:Double?
    
    func downloadImages(longitude: Double, latitude: Double, completionHandlerForDownloadingImage : @escaping (_ success:Bool,_ data: Response, _ error:String? ) -> Void){
        
        self.latitude = latitude
        self.longitude = longitude
        
        // create parameters
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.SearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.BoundingBox: bboxString(),
            FlickrConstants.FlickrParameterKeys.SafeSearch: FlickrConstants.FlickrParameterValues.UseSafeSearch,
            FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.MediumURL,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
        ]
        
        //create session
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            //Parse the Data using Decodable
            do{
                let response = try JSONDecoder().decode(Response.self, from: data)
                
                //return with response object
                completionHandlerForDownloadingImage(true, response, nil)
                
            } catch let jsonErr{
                print("Error serializing json data : \(jsonErr)")
            }
            
            
            
        }
        task.resume()
    }
    
    
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = self.latitude, let longitude = self.longitude {
            let minimumLon = max(longitude - FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.Flickr.APIScheme
        components.host = FlickrConstants.Flickr.APIHost
        components.path = FlickrConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
