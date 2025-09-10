//  FishSpottingViewController.swift
//  Fish_Identifier_App
//  Created by PGNV on 30/08/25.

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON


// Custom data model for a fishing spot
struct FishingSpot: Codable {
    let id: String
    let name: String
    let state: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let numberOfCatches: Int?
    let rbffid: Int
}

// Custom annotation to hold a FishingSpot object
class FishingSpotAnnotation: MKPointAnnotation {
    var fishingSpot: FishingSpot?
}

class FishSpottingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var serachBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locateMeButton: UIButton!
    @IBOutlet weak var layersBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stdbtn: UIButton!
    
    var locationManager: CLLocationManager?
    var lastAPICallRegion: MKCoordinateRegion?
    let minimumZoomLevelForAPI: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150)
    var bottomBarView: UIView?
    var selectedFishingSpot: FishingSpot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomConstraint.constant = -300
        locationManager = CLLocationManager()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        locationManager?.delegate = self
        checkLocationAuthorization()
        mapView.delegate = self
        mapView.mapType = .standard
        // Add a gesture recognizer to handle tap on the map to dismiss the bottom bar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func serachButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            searchVC.onPlaceSelected = { [weak self] place in
                self?.showPlaceOnMap(place: place)
            }
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    @IBAction func locateMeTapped(_ sender: UIButton) {
        centerToUserLocation()
    }
    
    @IBAction func LayerButton(_ sender: UIButton) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBottomView))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func standardButton(_ sender: UIButton) {
        mapView.mapType = .standard
        hideBottomView()
    }
    
    @IBAction func satelliteButton(_ sender: UIButton) {
        mapView.mapType = .satellite
        hideBottomView()
    }
    
    @IBAction func hybridButton(_ sender: UIButton) {
        mapView.mapType = .hybrid
        hideBottomView()
    }
    
    
    
    func showPlaceOnMap(place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let annotation = MKPointAnnotation()
        annotation.title = place.primary_name
        annotation.subtitle = place.state
        annotation.coordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Check if the zoom level is sufficient to make the API call
        if mapView.region.span.latitudeDelta < minimumZoomLevelForAPI.latitudeDelta && mapView.region.span.longitudeDelta < minimumZoomLevelForAPI.longitudeDelta {
            
            // Only call the API if the map region has changed significantly
            if let lastRegion = lastAPICallRegion,
               let currentRegion = getRegionFromMapRect(mapRect: mapView.visibleMapRect) {
                let centerDistance = CLLocation(latitude: lastRegion.center.latitude, longitude: lastRegion.center.longitude)
                    .distance(from: CLLocation(latitude: currentRegion.center.latitude, longitude: currentRegion.center.longitude))
                let deltaRatio = abs(lastRegion.span.latitudeDelta - currentRegion.span.latitudeDelta) / lastRegion.span.latitudeDelta
                
                // Use a threshold to prevent excessive API calls
                if centerDistance > 100 || deltaRatio > 0.1 {
                    fetchFishingSpots()
                }
            } else {
                fetchFishingSpots()
            }
        } else {
            // Remove annotations if the user zooms out too far
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Use a default pin for the user's location
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "fishingSpot"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Set the custom pin image
        annotationView?.image = UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? FishingSpotAnnotation,
           let spot = annotation.fishingSpot {
            showBottomBar(for: spot)
        }
    }
    
    // MARK: - API and UI Functions
    
//    private func fetchFishingSpots() {
//        let visibleMapRect = mapView.visibleMapRect
//        let topLeft = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
//        let bottomRight = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
//        
//        // Define the API URL with map boundaries
//        let url = "https://rutilus.fishbrain.com/maps/\(bottomRight.latitude),\(topLeft.longitude),\(topLeft.latitude),\(bottomRight.longitude)/explore?filter%5Btypes%5D=body_of_water"
//        
//        // Store the current region to prevent redundant API calls
//        lastAPICallRegion = getRegionFromMapRect(mapRect: visibleMapRect)
//
//        AF.request(url).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                let totalNumberOfCatches = json["properties"]["number_of_catches"].int
//
//                var newAnnotations: [MKAnnotation] = []
//                if let features = json["features"].array {
//                    for feature in features {
//                        if feature["properties"]["type"].string == "body_of_water",
//                           let primaryName = feature["properties"]["primary_name"].string,
//                           let state = feature["properties"]["state"].string,
//                           let latitudeString = feature["properties"]["latitude"].string,
//                           let longitudeString = feature["properties"]["longitude"].string,
//                           let rbff_id = feature["properties"]["rbff_id"].int,
//                           let latitude = Double(latitudeString),
//                           let longitude = Double(longitudeString) {
//                            
//                            let spot = FishingSpot(id: feature["id"].string ?? UUID().uuidString, name: primaryName, state: state, latitude: latitude, longitude: longitude, numberOfCatches: totalNumberOfCatches, rbffid: rbff_id)
//                            
//                            let annotation = FishingSpotAnnotation()
//                            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                            annotation.title = primaryName
//                            annotation.subtitle = state
//                            annotation.fishingSpot = spot
//                            
//                            newAnnotations.append(annotation)
//                        }
//                    }
//                }
//                self.mapView.addAnnotations(newAnnotations)
//                
//            case .failure(let error):
//                print("Error fetching fishing spots: \(error)")
//            }
//        }
//    }
//    
    private func fetchFishingSpots() {
        let visibleMapRect = mapView.visibleMapRect
        let topLeft = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
        let bottomRight = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
        
        let url = "https://rutilus.fishbrain.com/maps/\(bottomRight.latitude),\(topLeft.longitude),\(topLeft.latitude),\(bottomRight.longitude)/explore?filter%5Btypes%5D=body_of_water"
        
        lastAPICallRegion = getRegionFromMapRect(mapRect: visibleMapRect)
        
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let totalNumberOfCatches = json["properties"]["number_of_catches"].int
                
                if let features = json["features"].array {
                    for feature in features {
                        if feature["properties"]["type"].string == "body_of_water",
                           let primaryName = feature["properties"]["primary_name"].string,
                           let state = feature["properties"]["state"].string,
                           let latitudeString = feature["properties"]["latitude"].string,
                           let longitudeString = feature["properties"]["longitude"].string,
                           let rbff_id = feature["properties"]["rbff_id"].int,
                           let latitude = Double(latitudeString),
                           let longitude = Double(longitudeString) {
                            
                            let spot = FishingSpot(
                                id: feature["id"].string ?? UUID().uuidString,
                                name: primaryName,
                                state: state,
                                latitude: latitude,
                                longitude: longitude,
                                numberOfCatches: totalNumberOfCatches,
                                rbffid: rbff_id
                            )
                            
                            // ✅ Check if this annotation already exists
                            let alreadyExists = self.mapView.annotations.contains {
                                guard let existing = $0 as? FishingSpotAnnotation else { return false }
                                return existing.fishingSpot?.id == spot.id
                            }
                            
                            if !alreadyExists {
                                let annotation = FishingSpotAnnotation()
                                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                annotation.title = primaryName
                                annotation.subtitle = state
                                annotation.fishingSpot = spot
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                    }
                }
                
            case .failure(let error):
                print("Error fetching fishing spots: \(error)")
            }
        }
    }

    
    private func getRegionFromMapRect(mapRect: MKMapRect) -> MKCoordinateRegion? {
        let center = MKMapPoint(x: mapRect.midX, y: mapRect.midY).coordinate
        let span = MKCoordinateSpan(latitudeDelta: mapRect.size.height, longitudeDelta: mapRect.size.width)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func showBottomBar(for spot: FishingSpot) {
        // Remove any existing bottom bar
        bottomBarView?.removeFromSuperview()
        
        // Create the view for the bottom bar
        let barHeight: CGFloat = 160 // Increased height for the new label and button
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        let barFrame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: barHeight + safeAreaBottomInset)
        bottomBarView = UIView(frame: barFrame)
        bottomBarView?.backgroundColor = .systemBackground
        bottomBarView?.layer.cornerRadius = 10
        bottomBarView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        visualEffectView.frame = bottomBarView?.bounds ?? .zero
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bottomBarView?.addSubview(visualEffectView)
        
        // Add labels for the place name, state, and number of catches
        let nameLabel = UILabel()
        nameLabel.text = spot.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView?.addSubview(nameLabel)
        
        let stateLabel = UILabel()
        stateLabel.text = "State: \(spot.state)"
        stateLabel.font = UIFont.systemFont(ofSize: 16)
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView?.addSubview(stateLabel)
        
        let catchesLabel = UILabel()
        if let catches = spot.numberOfCatches {
            catchesLabel.text = "Catches: \(catches)"
        } else {
            catchesLabel.text = "Catches: N/A"
        }
        catchesLabel.font = UIFont.systemFont(ofSize: 16)
        catchesLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView?.addSubview(catchesLabel)
        
        // Add the "More Information" button
        let moreInfoButton = UIButton(type: .system)
        moreInfoButton.setTitle("More Information", for: .normal)
        moreInfoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
        moreInfoButton.addTarget(self, action: #selector(moreInfoButtonTapped), for: .touchUpInside)
        bottomBarView?.addSubview(moreInfoButton)
        
        self.selectedFishingSpot = spot
        
        // Update constraints to include the new label and position the button
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: bottomBarView!.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: bottomBarView!.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: bottomBarView!.trailingAnchor, constant: -20),
            
            stateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            stateLabel.leadingAnchor.constraint(equalTo: bottomBarView!.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: bottomBarView!.trailingAnchor, constant: -20),
            
            catchesLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 8),
            catchesLabel.leadingAnchor.constraint(equalTo: bottomBarView!.leadingAnchor, constant: 20),
            catchesLabel.trailingAnchor.constraint(equalTo: bottomBarView!.trailingAnchor, constant: -20),
            
            moreInfoButton.topAnchor.constraint(equalTo: catchesLabel.bottomAnchor, constant: 15),
            moreInfoButton.centerXAnchor.constraint(equalTo: bottomBarView!.centerXAnchor),
            moreInfoButton.widthAnchor.constraint(equalToConstant: 200),
            moreInfoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add the bar to the view and animate its appearance
        view.addSubview(bottomBarView!)
        UIView.animate(withDuration: 0.3) {
            self.bottomBarView?.frame.origin.y = self.view.frame.height - barHeight - safeAreaBottomInset
        }
    }
    
    private func hideBottomBar() {
        if let bottomBar = bottomBarView {
            UIView.animate(withDuration: 0.3, animations: {
                bottomBar.frame.origin.y = self.view.frame.height
            }) { _ in
                bottomBar.removeFromSuperview()
                self.bottomBarView = nil
            }
        }
    }
    
    @objc func moreInfoButtonTapped() {
        // Hide the bottom bar before navigating
        hideBottomBar()
        
        guard let selectedSpot = selectedFishingSpot else {
            print("No fishing spot selected.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailCatchesViewController") as? DetailCatchesViewController {
            
            // Pass the fishing spot data to the detail view controller
            detailVC.fishingSpot = selectedSpot
            print(selectedSpot)
            // Push the new view controller onto the navigation stack
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    @objc func handleMapTap(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Hide the bottom bar when the user taps on the map
            hideBottomBar()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Prevent the tap gesture from interfering with annotation selection
        if bottomView.frame.contains(touch.location(in: self.view)) {
            return false
        }
        return true
    }
    
    func checkLocationAuthorization() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show alert to enable permission
            break
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager?.startUpdatingLocation()
        case .none:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Center to User Location
    func centerToUserLocation() {
        if let location = locationManager?.location?.coordinate {
            let region = MKCoordinateRegion(center: location,latitudinalMeters: 1000,longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func hideBottomView() {
        bottomConstraint.constant = -300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension FishSpottingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // First time update → center map
        if let location = locations.last {
            let region = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: 1000,longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            // stop updating frequently to save battery
            locationManager?.stopUpdatingLocation()
        }
    }
}


