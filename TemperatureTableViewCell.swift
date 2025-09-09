//
//  TemperatureTableViewCell.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 08/09/25.
//

import UIKit

class TemperatureTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    func configure(with temperature: Temperature) {
            // Format the date string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: temperature.day) {
                dateFormatter.dateFormat = "EEEE, MMM d" // Example: "Monday, Sep 9"
                self.dayLabel.text = dateFormatter.string(from: date)
            } else {
                self.dayLabel.text = "Date N/A"
            }
            
            // Convert temperatures from Kelvin to Celsius and Fahrenheit
            let minC = temperature.minimumtemperature - 273.15
            let maxC = temperature.maximumtemperature - 273.15
            let minF = (temperature.minimumtemperature - 273.15) * 9/5 + 32
            let maxF = (temperature.maximumtemperature - 273.15) * 9/5 + 32
            
            self.tempLabel.text = String(format: "Min: %.1f°C (%.1f°F) | Max: %.1f°C (%.1f°F)", minC, minF, maxC, maxF)
            self.weatherLabel.text = temperature.weather
        }
}
