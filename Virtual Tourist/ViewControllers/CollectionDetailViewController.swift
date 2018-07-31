//
//  CollectionDetailViewController.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/30/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit

class CollectionDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageData : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageData = imageData{
            imageView.image = UIImage(data: imageData)
        }
        // Do any additional setup after loading the view.
    }

}
