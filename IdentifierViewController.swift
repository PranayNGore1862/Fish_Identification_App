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
        textView1.text = "\(data["identificationTips"][0].stringValue)"
        textView2.text = "\(data["identificationTips"][1].stringValue)"
        textView3.text = "\(data["identificationTips"][2].stringValue)"
        familyLabel.text = "Family: \(data["fishInfo"]["family"].stringValue)"
        orderLabel.text = "Order: \(data["fishInfo"]["order"].stringValue)"
        dietLabel.text = "Diet: \(data["fishInfo"]["diet"].stringValue)"
        lifeSpan.text = "Life Span: \(data["fishInfo"]["lifespan"].stringValue)"
        watertypeLabel.text = "Water Type: \(data["fishInfo"]["waterType"].stringValue)"
    }
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var fishName: UILabel!
    @IBOutlet weak var scientificName: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var dietLabel: UILabel!
    @IBOutlet weak var lifeSpan: UILabel!
    @IBOutlet weak var watertypeLabel: UILabel!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var textView3: UITextView!
    
    
    var finalImage: UIImage!
    var fishData: JSON?
    
//    @IBAction func addCollectionView(_ sender: UIButton) {
//        guard let jsons = fishData, let images = finalImage else { return }
//        FishStorage.shared.saveFish(image: images, json: jsons)
//            
//            let alert = UIAlertController(title: "Success", message: "Added to My Collection", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//    }
    
}


