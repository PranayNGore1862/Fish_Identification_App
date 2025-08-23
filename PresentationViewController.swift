//
//  PresentationViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 22/08/25.
//

import UIKit
import SwiftyJSON

class PresentationViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fishname: UILabel!
    @IBOutlet weak var scientificnameLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    
    var fish: FishModel?
    var json: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fish = fish else { return }
        imageView.image = UIImage(contentsOfFile: fish.imagePath)
                
                // Load JSON
        if let data = try? Data(contentsOf: URL(fileURLWithPath: fish.jsonPath)) {
            json = try? JSON(data: data)
        }
                
        if let json = json {
            fishname.text = "Name: \(json["fishName"].stringValue)"
            scientificnameLbl.text = "Scientific Name: \(json["scientificName"].stringValue)"
            percentageLbl.text = "Confidence: \(json["confidence"].intValue)%"
        }
    }

    @IBAction func removeCltnButton(_ sender: UIButton) {
        if let fish = fish,
           let index = FishStorage.shared.loadFishes().firstIndex(where: { $0.id == fish.id }) {
            FishStorage.shared.removeFish(at: index)
            navigationController?.popViewController(animated: true)
        }
    }
}
