//
//  SpeciesViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 05/09/25.
//
//
import UIKit

class SpeciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var Species: [FishSpecies] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Species.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! SpeciesTableViewCell
        let speciesItem = Species[indexPath.row]
        cell.configure(with: speciesItem)
//        cell.imageView1.image = UIImage(named: Species[indexPath.row].imageOfSpecies)
//        cell.label.text = Species[indexPath.row].nameOfSpecies
        return cell
    }
    

}
