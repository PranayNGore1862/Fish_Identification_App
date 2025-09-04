//
//  DetailCatchesViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 04/09/25.
//

import UIKit

class DetailCatchesViewController: UIViewController {
    
    var fishingSpot: FishingSpot?

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeStateLabel: UILabel!
    
    // You can add more UI elements here to display catches, photos, etc.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if data was passed and update the UI
        if let spot = fishingSpot {
            self.title = spot.name
            placeNameLabel.text = "Place: \(spot.name)"
            placeStateLabel.text = "State: \(spot.state)"
            // Fetch more details (catches, photos, etc.) using the spot's ID if needed
        }
    }

}
