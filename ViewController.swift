//
//  ViewController.swift
//  Fish_Identifier_App
//
//  Created by PGNV on 20/08/25.
//

import UIKit
import QCropper

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropperViewControllerDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var cropperState: CropperState?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var uploadbtn: UIButton!
    @IBOutlet weak var takepicturebtn: UIButton!
    @IBOutlet weak var mycltnBtn: UIButton!
    
    @IBAction func uploadButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = true
        present(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func myCollectionButton(_ sender: UIButton) {
        let myCollectionVC = storyboard?.instantiateViewController(withIdentifier: "MyCollectionViewController") as! MyCollectionViewController
        self.navigationController?.pushViewController(myCollectionVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        let cropper = CropperViewController(originalImage: image)
        cropper.delegate = self
        picker.dismiss(animated: true){
            self.present(cropper, animated: true , completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)
        if let state = state,
           let cimage = cropper.originalImage.cropped(withCropperState: state) {
            cropperState = state
            print("Initial state:", cropper.isCurrentlyInInitialState)
            let pictureVC = storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            pictureVC.uploadedImage = cimage
            self.navigationController?.pushViewController(pictureVC, animated: true)
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.dismiss(animated: true , completion: nil)
    }
    
}
