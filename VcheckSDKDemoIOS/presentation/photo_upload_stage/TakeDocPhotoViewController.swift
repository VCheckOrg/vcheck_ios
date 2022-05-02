//
//  TakeDocPhotoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 02.05.2022.
//

import Foundation
import UIKit

class TakeDocPhotoViewController : UIViewController,
                                    UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var firstPhotoCard: RoundedView!
    
    @IBOutlet weak var secondPhotoCard: RoundedView!
    
    
    @IBOutlet weak var firstPhotoButton: RoundedView!
    
    @IBOutlet weak var secondPhotoButton: RoundedView!
    
    
    @IBOutlet weak var imgViewIconFirst: UIImageView!
    
    @IBOutlet weak var imgViewIconSecond: UIImageView!
    
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    
    override func viewDidLoad() {
        
        firstPhotoButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                   action: #selector (self.takePhoto(_:))))
        //imgViewIconFirst
    }
    
    
    @objc func takePhoto(_ sender:UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(picnum: Int = 0, _ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print("--- TOOK A PHOTO SUCCESFULLY")
        print(image.size)
    }
}
