//
//  SearchViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 03/09/25.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

struct Place {
    let id: Int
    let type: String
    let rbff_id: Int
    let primary_name: String
    let description: String
    let state: String
    let latitude: Double
    let longitude: Double
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var places: [Place] = []
    var onPlaceSelected: ((Place) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbarView.becomeFirstResponder()
        searchbarView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func searchPlaces(query: String) {
        guard !query.isEmpty else {
            self.places = []
            self.tableView.reloadData()
            return
        }

        let url = "https://rutilus.fishbrain.com/maps/search"
        let parameters: [String: Any] = [
            "s": query,
            "poi_types": ""
        ]

        AF.request(url, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var results: [Place] = []

                for placeJSON in json["results"].arrayValue {
                    let place = Place(
                        id: placeJSON["id"].intValue,
                        type: placeJSON["type"].stringValue,
                        rbff_id: placeJSON["rbff_id"].intValue,
                        primary_name: placeJSON["primary_name"].stringValue,
                        description: placeJSON["description"].stringValue,
                        state: placeJSON["state"].stringValue,
                        latitude: placeJSON["latitude"].doubleValue,
                        longitude: placeJSON["longitude"].doubleValue
                    )
                    results.append(place)
                }

                self.places = results
                self.tableView.reloadData()

            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPlaces(query: searchText)
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.primary_name
        cell.detailTextLabel?.text = "\(place.state) - \(place.description)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = places[indexPath.row]
        print("Selected: \(selectedPlace.primary_name) lat: \(selectedPlace.latitude), lon: \(selectedPlace.longitude)")
        onPlaceSelected?(selectedPlace)  // send data back
        navigationController?.popViewController(animated: true)
    }
}
