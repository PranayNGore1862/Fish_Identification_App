//
//  TemperatureViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 08/09/25.
//

import UIKit

class TemperatureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var temperatureTableView: UITableView!
    
    var temperatureData: [Temperature] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstReading = temperatureData.first {
            timeZoneLabel.text = "Time Zone: \(firstReading.timeZone)"
        } else {
            timeZoneLabel.text = "Time Zone: N/A"
        }
        temperatureTableView.delegate = self
        temperatureTableView.dataSource = self
        temperatureTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return temperatureData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell1", for: indexPath) as? TemperatureTableViewCell else {
                        return UITableViewCell()
                    }
                    
            let temperatureReading = temperatureData[indexPath.row]
            cell.configure(with: temperatureReading)
                    
            return cell
        }
}
