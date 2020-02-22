//
//  MapController.swift
//  RouteFinder-Application
//
//  Created by Daniel Vu on 2/21/20.
//  Copyright © 2020 UC Irvine. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var destLatitude : Double = 0
    var destLongitude : Double = 0
    var destName : String = ""
    
    let locationManager = CLLocationManager()
   
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationName: UILabel!
    
    @IBOutlet weak var backOutlet: UIButton!
    
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationName.layer.masksToBounds = true
        locationName.layer.cornerRadius = 8.0
        locationName.text = destName
        
        backOutlet.layer.masksToBounds = true
        backOutlet.layer.cornerRadius = 8.0
        
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 8.0
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }

        let sourceCoordinates = locationManager.location?.coordinate
        
        let destCoordinate = CLLocationCoordinate2D(latitude: destLatitude, longitude: destLongitude)
        
        //Pin the destination
        let annotation = MKPointAnnotation()
        annotation.coordinate = destCoordinate
        mapView.addAnnotation(annotation)
        
        let sourcePlacemark = MKPlacemark(coordinate : sourceCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinate)
        
        let sourceItem = MKMapItem(placemark : sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate(completionHandler: {
            response,error in
            
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        })
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        
//        mapView.camera.heading = newHeading.magneticHeading
//        mapView.setCamera(mapView.camera, animated: true)
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Map View Configurations
    /***************************************************************/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 10.0
        
        return renderer
    }
}
