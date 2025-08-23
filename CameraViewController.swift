//
//  CameraViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 20/08/25.
//

import UIKit
import Alamofire
import SwiftyJSON

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = uploadedImage
    }

    var uploadedImage: UIImage?
    var jsonResponse: JSON?

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var identifyBtn: UIButton!
    
    @IBAction func identifyButton(_ sender: UIButton) {
        uploadImagefunc(uploadImage: uploadedImage!)
    }
    
    func uploadImagefunc(uploadImage: UIImage) {
        let apiUrl = "https://raugen.com/api/ai/fish-species-identifier"
        guard let imageData = uploadImage.jpegData(compressionQuality: 0.8) else { return }
        let headers: HTTPHeaders = [
            "Cookie": "FCNEC=%5B%5B%22AKsRol_n0KPpbBGsxym2rl-ojLgrU1iuDp8Jsln4KWDYuxWob6_4ibh8rHtLqvxvU8XQkBv5187jGwAvMHGh7AOmxoq3-WNqaoirHBkFaGbh3snQapTS4btPAkld7q0OwRRxRtzZFMtD4CvjAKrpA-Ladv8c7RYb8Q%3D%3D%22%5D%5D; __Secure-authjs.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoiUklTSmdrWEtoOXplUk5najFzdWYyYlVTM2h4OEtrNHh6ZjlsaFpXODBxOEViaVk1b094aUNWOWhaUWdPaGRnN3o3U2pxbXlJVWI4bmw1NDJZZG9YSlEifQ..5QpFBarM1alvgeKuQFCEJw.Ipngsu0UNjgap-MsrvL5tNr2HKcVA2ydeuz3LNIQ8ciGbeXLZFg0_3Xpz2ZSzXGfEDXqP50osp4niuw_y-PE7QpNfJyvnceOB7TB3jz82VPWtazPqBJ31Th_UDfkQlO8Bj6B9CQRAF-n9i44dmLrOgEysSCV4ZfbXsSOY0MhXtFt5SNwYNjBhUQpvZ2eYG6z-Kv8ubsAtZ1V40s04sL4qYgctQG_jEb_hXKOdJfgNaDI2iWrViaMrQoPaWfQ6L-XEzXo47HLzom3Vzmo9wVp6M3VMky_3p9jjP72syeRP2OCXuTZzkq27CA8-sroV5A7GKqiN12Au_ybHOmWdM4lUrzg4qGV1rd4CoZbkz6WqrK2UXJ0yDdCLbFVCPdE7A7lFrU-cf3EGy5WGDqWhooF_w.dvD43xwdxMdVBSYeLtxUGEZXzo7d2_iVghDpYF5OwRc; _ga=GA1.1.1482289199.1755671446; _ga_158C9Y0CED=GS2.1.s1755748277$o5$g1$t1755748748$j60$l0$h0; __eoi=ID=bda9fe63aab54ba0:T=1755671446:RT=1755748729:S=AA-AfjbKALXo4E_bJ_cRC8K9brLa; __gads=ID=bf2b373cb678340e:T=1755671446:RT=1755748729:S=ALNI_MaNHk6sX0q9Dy4qZWJaHlzTpg7huA; __gpi=UID=000011833f57f3b3:T=1755671446:RT=1755748729:S=ALNI_MY0glRyrl-sw7jA2rC3CAZM9BlMBw; __Host-authjs.csrf-token=e32358cf6f8bac12e54b3a2dae23acfb0c448ff71a862780c9d319ae4844dc46%7C332e4713e3f43e2dd7a38989fdd3f680c606dcee0aec6f5982ec75d1f4e01ea4; __Secure-authjs.callback-url=https%3A%2F%2Fraugen.com; csrf_token=ddc9a109-9f25-497b-9407-324f4a90c835"
        ]
        
        let loadingAlert = alert()
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "fish.jpg", mimeType: "image/jpeg")
        }, to: apiUrl, method: .post, headers: headers).responseJSON { response in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) { // dismiss first
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.jsonResponse = json
                        self.identifierVC(with: json)
                    case .failure(let error):
                        print("Error uploading image: \(error)")
                    }
                }
            }
        }
    }
    
    func identifierVC(with json: JSON) {
        let thirdVC = storyboard?.instantiateViewController(withIdentifier: "IdentifierViewController") as? IdentifierViewController
        thirdVC?.finalImage = uploadedImage
        thirdVC?.fishData = json["analysis"]
        self.navigationController?.pushViewController(thirdVC!, animated: true)
    }
    
    @discardableResult
    func alert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Identifying fish...\n\n", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingIndicator.color = .black
        alert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])
        present(alert, animated: true, completion: nil)
        return alert
    }
}

