//
//  CatchesCollectionViewCell.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 05/09/25.
//

import UIKit
import Alamofire
import SwiftyJSON

class CatchesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var fishImageView: UIImageView!
    @IBOutlet weak var speciesLabel: UILabel!
    
    func configure(with catchItem: FishCatches) {
        speciesLabel.text = catchItem.name
        
        // Use AlamofireImage or a similar library for image loading
        // For demonstration, here's a placeholder
//     fishImageView.af.setImage(withURL: URL(string: catchItem.imageUrl)!)
        
        // Simple URLSession for demonstration without AlamofireImage
        if let url = URL(string: catchItem.imageUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.fishImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
