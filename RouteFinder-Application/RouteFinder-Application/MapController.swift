import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var destLatitude: Double = 0
    var destLongitude: Double = 0
    var destName: String = ""

    let locationManager = CLLocationManager()
    private var routeRequested = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var backOutlet: UIButton!

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

        let destination = CLLocationCoordinate2D(
            latitude: destLatitude,
            longitude: destLongitude
        )
        let annotation = MKPointAnnotation()
        annotation.coordinate = destination
        annotation.title = destName
        mapView.addAnnotation(annotation)

        guard CLLocationManager.locationServicesEnabled() else {
            mapView.setRegion(
                MKCoordinateRegion(
                    center: destination,
                    latitudinalMeters: 1500,
                    longitudinalMeters: 1500
                ),
                animated: false
            )
            return
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !routeRequested, let source = locations.last?.coordinate else {
            return
        }

        routeRequested = true
        locationManager.stopUpdatingLocation()
        requestRoute(from: source)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }

    private func requestRoute(from source: CLLocationCoordinate2D) {
        let destination = CLLocationCoordinate2D(
            latitude: destLatitude,
            longitude: destLongitude
        )

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("Directions error: \(error)")
                return
            }

            guard let route = response?.routes.first else {
                return
            }

            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 40, bottom: 50, right: 40),
                animated: true
            )
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 6.0
        return renderer
    }
}
