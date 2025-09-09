//
//  DetailCatchesViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 04/09/25.
//

import UIKit
import Alamofire
import SwiftyJSON

struct FishCatches: Codable {
    let name: String
    let imageUrl: String
}

struct FishSpecies : Codable {
    let nameOfSpecies: String
    let imageOfSpecies: String
//    let id: Int
//    let displayDescription: String
//    let identifyDescription: String
//    let wheretoCatchDescription: String
//    let howtoCatchDescription: String
//    let lurebaitsDescription: String
//    let catchEase: String
//    let region: [String]
//    let habitat: Habitat
//    let subhabitat: SubHabitat
//    let lure: Lure
//    let technique: Technique
//    let speciesname: String
}

struct Temperature: Codable {
    let timeZone: String
    let day: String
    let minimumtemperature: Double
    let maximumtemperature: Double
    let weather: String
}


class DetailCatchesViewController: UIViewController {
    
    var fishingSpot: FishingSpot?
    var catchesData: [FishCatches] = []
    var speciesdata: [FishSpecies] = []
    var temperatureData: [Temperature] = []

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeStateLabel: UILabel!
    @IBOutlet weak var catchesLabel: UILabel!
    @IBOutlet weak var catches: UIButton!
    @IBOutlet weak var species: UIButton!
    @IBOutlet weak var TemperatureBtn: UIButton!
    // You can add more UI elements here to display catches, photos, etc.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if data was passed and update the UI
        if let spot = fishingSpot {
            self.title = spot.name
            placeNameLabel.text = "Place: \(spot.name)"
            placeStateLabel.text = "State: \(spot.state)"
            // Fetch more details (catches, photos, etc.) using the spot's ID if needed
            if let catches = spot.numberOfCatches {
                catchesLabel.text = "Total Catches: \(catches)"
            } else {
                catchesLabel.text = "Total Catches: N/A"
            }
        }
    }
    @IBAction func catchesButton(_ sender: UIButton) {
        catchesAPI()
    }
    
    @IBAction func speciesButton(_ sender: UIButton) {
        speciesAPI()
    }
    
    @IBAction func temperatureButton(_ sender: UIButton) {
        temperatureAPI()
    }
    
    func catchesAPI(){
        
        guard let rbffId = fishingSpot?.rbffid else {
            print("Error: Fishing spot or its ID is missing.")
            return
        }
        print(rbffId)
        let url = "https://rutilus.fishbrain.com/bodies_of_water/\(rbffId)/catches"
        
        let parameters: [String: Any] = [
            "q[s]": "created_at desc",
            "q[photos_counter_gt]": 0,
            "verbosity": "rbff"
        ]
        
        let headers: HTTPHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "no-cache"
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                var parsedCatches: [FishCatches] = []
                
                // The main JSON response is an array of objects
                if let catchesArray = json.array{
                    for catchData in catchesArray {
                        // Safely extract the species localized name and the first photo's base_url
                        if let speciesName = catchData["species"]["localized_name"].string,
                           let firstPhoto = catchData["photos"].array?.first,
                           let imageURL = firstPhoto["photo"]["base_url"].string {
                            let newCatch = FishCatches(name: speciesName, imageUrl: imageURL)
                            parsedCatches.append(newCatch)
                        }
                    }
                }
                print(parsedCatches)
                self.catchesData = parsedCatches
                // Print the parsed data to verify
                print("Parsed Catches: \(self.catchesData)")
                
                // Trigger the segue or call a function to display the catches
                self.navigateToCatchesViewController()
                
            case .failure(let error):
                print("Error fetching catches: \(error)")
            }
        }
    }
    
    func navigateToCatchesViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let catchesVC = storyboard.instantiateViewController(withIdentifier: "CatchesViewController") as? CatchesViewController {
            catchesVC.catches = self.catchesData
            navigationController?.pushViewController(catchesVC, animated: true)
        }
    }
    
    func speciesAPI(){
        
        guard let rbffId = fishingSpot?.rbffid else {
            print("Error: Fishing spot or its ID is missing.")
            return
        }
        
        let url = "https://rutilus.fishbrain.com/bodies_of_water/\(rbffId)?verbosity=2"
        
        let parameters: [String: Any] = [
            "verbosity": 2
        ]
        
        let headers: HTTPHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "no-cache"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { [weak self]response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var parsedSpecies: [FishSpecies] = []
                if let speciesArray = json["rbff_species"].array{
                    for speciesObject in speciesArray{
                        if let speciesName = speciesObject["primary_name"].string,
                           let speciesImageUrl = speciesObject["image"]["base_url"].string{
                            let newSpecies = FishSpecies(nameOfSpecies: speciesName, imageOfSpecies: speciesImageUrl)
                            parsedSpecies.append(newSpecies)
                        }
                    }
                }
                self.speciesdata = parsedSpecies
                print(speciesdata)
                self.navigateTOSpeciesViewController()
                
            case .failure(let error):
                print("Error fetching species data: \(error)")
            }
        }
    }
    
    func navigateTOSpeciesViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let speciesVC = storyboard.instantiateViewController(withIdentifier: "SpeciesViewController") as? SpeciesViewController {
            speciesVC.Species = self.speciesdata
            navigationController?.pushViewController(speciesVC, animated: true)
        }
    }
    
    func temperatureAPI(){
        let url = "https://rutilus.fishbrain.com/maps/\(fishingSpot!.latitude),\(fishingSpot!.longitude)/daily_weather_forecast"
        
        let parameters: [String: Any] = [
            "hours_ahead":168
        ]
        
        let headers: HTTPHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "no-cache"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { [weak self] response in
            guard let self = self else { return }
            print(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                var parsedTemperature: [Temperature] = []

                guard let areaOfTemperature = json["time_zone"].string else {
                    print("Time zone not found in JSON.")
                    return
                }

                if let temperatureData = json["readings"].array {
                    for temperature in temperatureData {
                        if let timeStamp = temperature["reading_at"].string,
                           let temperatureMin = temperature["temperature_min"].double,
                           let temperatureMax = temperature["temperature_max"].double,
                           let weathers = temperature["wwo_condition"]["localized_name"].string {
                            let newTemperature = Temperature(timeZone: areaOfTemperature, day: timeStamp, minimumtemperature: temperatureMin, maximumtemperature: temperatureMax, weather: weathers)
                            parsedTemperature.append(newTemperature)
                        }
                    }
                }
                self.temperatureData = parsedTemperature
                self.navigationTOTemperatureViewController()

            case .failure(let error):
                print("Error getting Temperature Data: \(error)")
            }
        }
        
    }
    
    func navigationTOTemperatureViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let temperatureVC = storyboard.instantiateViewController(withIdentifier: "TemperatureViewController") as? TemperatureViewController {
            temperatureVC.temperatureData = self.temperatureData
            navigationController?.pushViewController(temperatureVC, animated: true)
        }
    }
    
}
