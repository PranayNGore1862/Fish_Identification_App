//
//  Model.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 22/08/25.
//

import Foundation
import UIKit
import SwiftyJSON

struct FishModel: Codable {
    let id: String           // unique id
    let name: String         // fish name
    let imagePath: String    // path to image
    let jsonPath: String     // path to json
}
