//
//  CatchesViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 05/09/25.
//

import UIKit

class CatchesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    var catches: [FishCatches] = []
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Set up your UICollectionViewLayout here
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(catches.count)
        return catches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! CatchesCollectionViewCell
        let catchItem = catches[indexPath.row]
        cell.configure(with: catchItem)
        return cell
    }
    
}
