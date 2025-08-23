//
//  IdentifierViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 20/08/25.
//

import UIKit
import Alamofire
import SwiftyJSON

class IdentifierViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data = fishData else { return }
        uploadedImage.image = finalImage
        fishName.text = "Name: \(data["fishName"].stringValue)"
        scientificName.text = "Scientific: \(data["scientificName"].stringValue)"
        confidenceLabel.text = "Confidence: \(data["confidence"].intValue)%"
        //        physicalCharacteristics.text = "Size: \(data["physicalCharacteristics"]["size"].stringValue)"
        //        physicalCharacteristics.text = "Body Shape: \(data["physicalCharacteristics"]["bodyShape"].stringValue)"
        //        physicalCharacteristics.text = "Color: \(data["physicalCharacteristics"]["coloration"].stringValue)"
        //        physicalCharacteristics.text = "Fins: \(data["physicalCharacteristics"]["fins"].stringValue)"
        //        fishInfoLabel.text = "Family: \(data["fishInfo"]["family"].stringValue)"
        //        fishInfoLabel.text = "Order: \(data["fishInfo"]["order"].stringValue)"
        //        fishInfoLabel.text = "Diet: \(data["fishInfo"]["diet"].stringValue)"
    }
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var fishName: UILabel!
    @IBOutlet weak var scientificName: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var addCltnBtn: UIButton!
    //    @IBOutlet weak var physicalCharacteristics: UILabel!
    //    @IBOutlet weak var fishInfoLabel: UILabel!
    //    @IBOutlet weak var habitatLabel: UILabel!
    //    @IBOutlet weak var behaivorlabel: UILabel!
    //    @IBOutlet weak var identifiactioLabel: UILabel!
    //    @IBOutlet weak var seasonalLabel: UILabel!
    //    @IBOutlet weak var similarspeciesLabel: UILabel!
    
    var finalImage: UIImage!
    var fishData: JSON?
    
    @IBAction func addCollectionView(_ sender: UIButton) {
        guard let jsons = fishData, let images = finalImage else { return }
        FishStorage.shared.saveFish(image: images, json: jsons)
            
            let alert = UIAlertController(title: "Success", message: "Added to My Collection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
    }
    
}


