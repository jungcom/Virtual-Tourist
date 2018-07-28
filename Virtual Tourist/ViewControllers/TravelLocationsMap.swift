//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/23/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMap: UIViewController, UIGestureRecognizerDelegate {

    var pins = [Pin]()
    var pinned = false
    var passedPin : Pin?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let pinsFrom = try CoreDataPersistence.context.fetch(fetchRequest)
            self.pins = pinsFrom
        } catch {}
        setUpMapView()
        setUpPins()
    }

    /*@IBAction func addPinOnTap(_ sender: UITapGestureRecognizer){
        addPins(sender)
    }*/
    
    @IBAction func addPinOnLongPress(_ sender: UILongPressGestureRecognizer) {
        
        // handle long pressing for more than 1 second
        if !pinned {
            pinned = true
            addPins(sender)
        }
        
        if sender.state == .ended{
            print("long press ended")
            pinned = false
        }
        
    }
    
    fileprivate func addPins(_ sender: UIGestureRecognizer) {
        //find current
        let location = sender.location(in: mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)

        //create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        let pinClLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        lookUpLocationName(clLocation: pinClLocation) { (pinClPlacemark) in
            annotation.title = pinClPlacemark?.name
            self.mapView.addAnnotation(annotation)
            
            ///////// MARK: Saving the pin with Core Data /////////
            let pin = Pin(context: CoreDataPersistence.context)
            pin.latitude = locationCoordinate.latitude
            pin.longitude = locationCoordinate.longitude
            pin.name = pinClPlacemark?.name
            CoreDataPersistence.saveContext()
            /////////////////////////////////////////////////
            
            //Update UI
            self.pins.append(pin)
            self.mapView.reloadInputViews()

            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare segue")
        if let destin = segue.destination as? UINavigationController {
            let photoAblumController = destin.viewControllers.first as? PhotoAlbumCollectionViewController
            photoAblumController?.pin = passedPin
        }
    }
    
    func lookUpLocationName(clLocation: CLLocation, completionHandler: @escaping (CLPlacemark?) -> Void){
        let geocoder = CLGeocoder()
        
        // Look up the location name
        geocoder.reverseGeocodeLocation(clLocation,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                print("added Pin \(self.mapView.annotations.count)")
                                                completionHandler(firstLocation)
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                print("no string found")
                                                completionHandler(nil)
                                            }
        })
    }
    
    
}


extension TravelLocationsMap: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "savedLongitudeDelta")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "savedLatitudeDelta")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "savedLongitude")
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "savedLatitude")
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //MARK: TODO - Create Predicate with Unique ID.
            let name = view.annotation?.title
            let lat = view.annotation?.coordinate.latitude
            let long = view.annotation?.coordinate.longitude
            print("name : \(name), lat: \(lat), long: \(long)")
            let namePredicate = NSPredicate(format: "name == %@", (name ?? "")!)
            //let latPredicate = NSPredicate(format: "latitude == %@", (lat ?? 0))
            //let longPredicate = NSPredicate(format: "longitude == %@", (long ?? 0))
            //let predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, latPredicate])
            
            //make a fetchrequest with the predicates
            let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
            fetchRequest.predicate = namePredicate
            do {
                let pin = try CoreDataPersistence.context.fetch(fetchRequest)
                self.passedPin = pin.first
                performSegue(withIdentifier: "toPhotoAlbum", sender: self)
                print("Fetch Request successful. Passed Pin: \(pin.first?.name ?? "No pin")")
            } catch let err{
                print("\(err)")
            }
            
            
        }
    }
    
    func setUpMapView(){
        // Set up Region and Zoom level
        let longitudeDelta = UserDefaults.standard.double(forKey: "savedLongitudeDelta")
        let latitudeDelta = UserDefaults.standard.double(forKey: "savedLatitudeDelta")
        let longitude = UserDefaults.standard.double(forKey: "savedLongitude")
        let latitude = UserDefaults.standard.double(forKey: "savedLatitude")
        
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: false)
    }
    
    // Set up Pins
    func setUpPins(){
        var annotation : MKPointAnnotation
        var coordinates : CLLocationCoordinate2D
        for pin in pins{
            annotation = MKPointAnnotation()
            coordinates = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.coordinate = coordinates
            annotation.title = pin.name
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
}

