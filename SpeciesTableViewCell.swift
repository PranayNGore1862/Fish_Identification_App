//
//  SpeciesTableViewCell.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 08/09/25.
//

import UIKit

class SpeciesTableViewCell: UITableViewCell {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with speciesItem: FishSpecies) {
        label.text = speciesItem.nameOfSpecies
        
        // Use AlamofireImage or a similar library for image loading
        // For demonstration, here's a placeholder
        // AlamofireImage: fishImageView.af.setImage(withURL: URL(string: catchItem.imageUrl)!)
        
        // Simple URLSession for demonstration without AlamofireImage
        if let url = URL(string: speciesItem.imageOfSpecies) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.imageView1.image = UIImage(data: data)
                }
            }.resume()
        }
    }

}
