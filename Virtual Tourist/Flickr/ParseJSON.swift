//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

struct Response:Decodable{
    let photos : Photos
    let stat: String
}

struct Photos:Decodable{
    let page:Int
    let pages: Int
    let perpage:Int
    let total: String
    let photo: [ArrOfPhotos]
}

struct ArrOfPhotos:Decodable{
    let url_m:String?
    let title:String
    
}

extension FlickrClient{
    
    //shared instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
