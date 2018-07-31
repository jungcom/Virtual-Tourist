//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

private let reuseIdentifier = "PhotoAlbumCollectionViewCell"

class PhotoAlbumCollectionViewController: UICollectionViewController {
    
    var pin:Pin!
    var arrPhoto = [NSData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("latitude : \(pin.latitude ?? 0.0)")
        print("longitude : \(pin.longitude ?? 0.0)")
        self.navigationItem.title = pin?.name
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        FlickrClient.sharedInstance().downloadImages(longitude: pin.longitude, latitude: pin.latitude) { (success, response, err) in
            if success{
                print("Download Successful")
                self.saveImages(response)
            } else {
                print("Download Unsuccessful")
            }
        }
    }

    //save Images to arrPhotos
    func saveImages(_ response:Response){
        for i in 0...20{
            print(response.photos.photo[i].url_m ?? "No URL")
            
            if let urlString = response.photos.photo[i].url_m {
                let imageURL = URL(string: urlString)
                
                //convert url into image data
                if let imageData = try? NSData(contentsOf: imageURL!) {
                    print("appended data to array")
                    arrPhoto.append(imageData!)
                    //Update UI
                    performUIUpdatesOnMain {
                        self.collectionView?.reloadData()
                    }
                }
            }
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
        return 20
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
    
        // Configure the cell
        
        if (indexPath.row + 1) <= arrPhoto.count {
            cell.imageView.image = UIImage(data:arrPhoto[indexPath.row] as Data)
        } else {
            cell.imageView.image = UIImage(named: "placeholder")
        }
        cell.imageView.layer.cornerRadius = 20
        cell.imageView.clipsToBounds = true
    
        return cell
    }

}
