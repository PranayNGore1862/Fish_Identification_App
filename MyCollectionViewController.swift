//
//  MyCollectionViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 22/08/25.
//

import UIKit
import SwiftyJSON

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fishes = FishStorage.shared.loadFishes()
            collectionView.reloadData()
        }
    
    var fishes: [FishModel] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! MyCollectionViewCell
        let fish = fishes[indexPath.row]
        cell.imageView.image = UIImage(contentsOfFile: fish.imagePath)
        cell.labelView.text = fish.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fish = fishes[indexPath.row]
        let presentationVC:PresentationViewController = self.storyboard?.instantiateViewController(withIdentifier: "PresentationViewController") as! PresentationViewController
        presentationVC.fish = fish
        self.navigationController?.pushViewController(presentationVC, animated: true)
    }
    
    
}
