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
}

// Custom annotation to hold a FishingSpot object
class FishingSpotAnnotation: MKPointAnnotation {
    var fishingSpot: FishingSpot?
}

class FishSpottingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var serachBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var locationManager: CLLocationManager!
    var lastAPICallRegion: MKCoordinateRegion?
    let minimumZoomLevelForAPI: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    var bottomBarView: UIView?
    var selectedFishingSpot: FishingSpot?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self

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

    private func fetchFishingSpots() {
        let visibleMapRect = mapView.visibleMapRect
        let topLeft = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
        let bottomRight = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
        
        // Define the API URL with map boundaries
        let url = "https://rutilus.fishbrain.com/maps/\(bottomRight.latitude),\(topLeft.longitude),\(topLeft.latitude),\(bottomRight.longitude)/explore?filter%5Btypes%5D=body_of_water"

        // Store the current region to prevent redundant API calls
        lastAPICallRegion = getRegionFromMapRect(mapRect: visibleMapRect)
        print(lastAPICallRegion as Any)
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                // Clear existing fishing spot annotations
                let fishingSpotAnnotations = self.mapView.annotations.filter { $0 is FishingSpotAnnotation }
                self.mapView.removeAnnotations(fishingSpotAnnotations)
                
                var newAnnotations: [MKAnnotation] = []
                if let features = json["features"].array {
                    for feature in features {
                        if feature["properties"]["type"].string == "body_of_water",
                           let primaryName = feature["properties"]["primary_name"].string,
                           let state = feature["properties"]["state"].string,
                           let latitudeString = feature["properties"]["latitude"].string,
                           let longitudeString = feature["properties"]["longitude"].string,
                           let latitude = Double(latitudeString),
                           let longitude = Double(longitudeString) {
                            
                            let spot = FishingSpot(id: feature["id"].string ?? UUID().uuidString, name: primaryName, state: state, latitude: latitude, longitude: longitude)
                            
                            let annotation = FishingSpotAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            annotation.title = primaryName
                            annotation.subtitle = state
                            annotation.fishingSpot = spot
                            
                            newAnnotations.append(annotation)
                        }
                    }
                }
                self.mapView.addAnnotations(newAnnotations)
                
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
        let barHeight: CGFloat = 160 // Increased height to accommodate the button
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

        // Add labels for the place name and state
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

        // Add the "More Information" button
        let moreInfoButton = UIButton(type: .system)
        moreInfoButton.setTitle("More Information", for: .normal)
        moreInfoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
        self.selectedFishingSpot = spot // Store the spot here
        moreInfoButton.addTarget(self, action: #selector(moreInfoButtonTapped), for: .touchUpInside)
        bottomBarView?.addSubview(moreInfoButton)

        // Store the selected fishing spot on the button so we can access it later
        // You could also use a property on the view controller to store the selected spot
        moreInfoButton.tag = Int(spot.id) ?? 0 // Assuming 'id' is a number
        
        // An easier way to pass the data would be to use a closure or a property
        // For this example, we'll store the spot in a property
        self.selectedFishingSpot = spot

        // Add constraints to position the labels and button
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: bottomBarView!.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: bottomBarView!.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: bottomBarView!.trailingAnchor, constant: -20),
            
            stateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            stateLabel.leadingAnchor.constraint(equalTo: bottomBarView!.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: bottomBarView!.trailingAnchor, constant: -20),
            
            moreInfoButton.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 15),
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
        return true
    }
    
   
}


