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
    var refToPhotoForDelete = [Photo]()
    let numberOfImages = 0...20
    var maxSize = 0
    var downloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("latitude : \(pin.latitude ?? 0.0)")
        print("longitude : \(pin.longitude ?? 0.0)")
        self.navigationItem.title = pin.name

        // Do any additional setup after loading the view.
        if let allImageData = pin.photos?.allObjects.first{
            loadSavedImages()
            
        } else {
            downloading = true
            FlickrClient.sharedInstance().downloadImages(longitude: pin.longitude, latitude: pin.latitude) { (success, response, err) in
                if success{
                    print("Download Successful")
                    self.saveImages(response)
                    
                    self.saveToCoreData()
                    self.downloading = false
                } else {
                    print("Download Unsuccessful")
                    self.downloading = false
                    
                }
            }
        }
    }

    @IBAction func reDownloadImages(_ sender: UIBarButtonItem) {
        FlickrClient.sharedInstance().downloadImages(longitude: pin.longitude, latitude: pin.latitude) { (success, response, err) in
            if success{
                print("Download Successful")
                self.deleteImagesInCoreData()
                self.saveImages(response)
                
                self.saveToCoreData()
            } else {
                print("Download Unsuccessful")
                
            }
        }
    }
    
    func deleteImagesInCoreData(){
        pin.removeFromPhotos(pin.photos!)
        CoreDataPersistence.saveContext()
        print("This pin has \(pin.photos?.count) photos")
    }
    
    fileprivate func loadSavedImages() {
        //////////Sort ARRAY
        let sectionSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        if let allSortedDataArray = pin.photos?.sortedArray(using: [sectionSortDescriptor]){
            print("Contains Data with: \(allSortedDataArray.count) images")
            for photo in allSortedDataArray{
                let aPhoto = photo as! Photo
                if let image = aPhoto.image {
                    arrPhoto.append(image as NSData)
                }
            }
            
            //Update UI
            performUIUpdatesOnMain {
                self.collectionView?.reloadData()
            }
        }
    }
    
    func saveToCoreData(){
        //Saves ArrPhoto to the Core Data Stack
        for i in numberOfImages{
            if i < maxSize{
            let photo = Photo(context: CoreDataPersistence.context)
            photo.image = arrPhoto[i] as Data
            // ID for Sorting
            photo.id = Int16(i)
            
            pin.addToPhotos(photo)
                
            //reference of the photos object for later deletion
            refToPhotoForDelete.append(photo)
                
            CoreDataPersistence.saveContext()
            }
        }
        
    }
    //save Images to arrPhotos
    func saveImages(_ response:Response){
        //delete current Images in current pin
        arrPhoto = [NSData]()
        
        for i in numberOfImages{
            
            maxSize = response.photos.photo.count
            if i < maxSize {
                let randomN = arc4random_uniform(UInt32(maxSize))
                if let urlString = response.photos.photo[Int(randomN)].url_m {
                    let imageURL = URL(string: urlString)
                
                    //convert url into image data
                    if let imageData = try? NSData(contentsOf: imageURL!) {
                        print("appended data to array")
                        if let imageData = imageData{
                        arrPhoto.append(imageData)
                        }
                        //Update UI
                        performUIUpdatesOnMain {
                            self.collectionView?.reloadData()
                        }
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
        if downloading{
            return 20
        }else{
            return arrPhoto.count
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performUIUpdatesOnMain {
            self.collectionView?.reloadData()
        }
        let alertController = UIAlertController(title: "View Or Delete?", message:
            "Would you like to view or delete the image?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "View", style: UIAlertActionStyle.default,handler: {(action) in
            let detailController = self.storyboard?.instantiateViewController(withIdentifier: "CollectionDetailViewController") as! CollectionDetailViewController
            detailController.imageData = self.arrPhoto[indexPath.row] as Data
            self.navigationController?.pushViewController(detailController, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default,handler: {(action) in
            //Delete selected image from UI and CoreData

            //Delete from Core Data
            let photo = self.refToPhotoForDelete[indexPath.row]
            CoreDataPersistence.context.delete(photo)
            CoreDataPersistence.saveContext()
            
 
            //Delete from UI
            self.arrPhoto.remove(at: indexPath.row)
            self.refToPhotoForDelete.remove(at: indexPath.row)
            self.collectionView?.deleteItems(at: [indexPath])
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

}
