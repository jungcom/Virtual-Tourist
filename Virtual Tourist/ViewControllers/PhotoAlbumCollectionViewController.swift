//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PhotoAlbumCollectionViewCell"

class PhotoAlbumCollectionViewController: UICollectionViewController {
    
    var latitude : Double? = nil
    var longitude : Double? = nil
    var arrPhoto = [NSData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("latitude : \(latitude ?? 0.0)")
        print("longitude : \(longitude ?? 0.0)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        if let longitude = longitude, let latitude = latitude{
            FlickrClient.sharedInstance().downloadImages(longitude: longitude, latitude: latitude) { (success, response, err) in
                if success{
                    print("Download Successful")
                    self.saveImages(response)
                } else {
                    print("Download Unsuccessful")
                }
            }
        }
    }

    //save Images to arrPhotos
    func saveImages(_ response:Response){
        for i in 0...15{
            print(response.photos.photo[i].url_m ?? "No URL")
            
            if let urlString = response.photos.photo[i].url_m {
                let imageURL = URL(string: urlString)
                
                //convert url into image data
                if let imageData = try? NSData(contentsOf: imageURL!) {
                    print("appended data to array")
                    arrPhoto.append(imageData!)
                }
            }
        }
        
        //Update UI
        performUIUpdatesOnMain {
            self.collectionView?.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // dismiss view
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrPhoto.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
    
        // Configure the cell
        
        cell.imageView.image = UIImage(data:arrPhoto[indexPath.row] as Data)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
