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
    
    
    @IBOutlet weak var deleteFirstPhotoBtn: UIImageView!
    
    @IBOutlet weak var deleteSecondPhotoBtn: UIImageView!
    
    
    @IBOutlet weak var tvFirstCardTitle: UILabel!
    
    @IBOutlet weak var tvSecondCardTitle: UILabel!
    
    
    var selectedDocType: DocType? = nil
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    var currentPhotoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
    
    
    override func viewDidLoad() {
        
        self.selectedDocType = DocType.docCategoryIdxToType(categoryIdx: KeychainHelper.shared.getSelectedDocTypeWithData()!.category!)
        
        if (self.selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
            
            setClickListenerForFistPhotoBtn()
            setClickListenerForSecondPhotoBtn()
        }
        if (self.selectedDocType == DocType.FOREIGN_PASSPORT) {
            secondPhotoCard.isHidden = true
            
            setClickListenerForFistPhotoBtn()
        }
        if (self.selectedDocType == DocType.ID_CARD) {
            
            setClickListenerForFistPhotoBtn()
            setClickListenerForSecondPhotoBtn()
        }
        
        
        
    }
    
    func setClickListenerForFistPhotoBtn() {
        let tapped1 = PhotoUploadTapGesture.init(target: self, action: #selector(handleTap))
        tapped1.photoTakeCase = PhotoTakeCase.FIRST
        tapped1.numberOfTapsRequired = 1
        self.firstPhotoButton.addGestureRecognizer(tapped1)
    }
    
    func setClickListenerForSecondPhotoBtn() {
        let tapped2 = PhotoUploadTapGesture.init(target: self, action: #selector(handleTap))
        tapped2.photoTakeCase = PhotoTakeCase.SECOND
        tapped2.numberOfTapsRequired = 1
        self.secondPhotoButton.addGestureRecognizer(tapped2)
    }
    
    
    @objc func takePhoto(_ sender:UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        print("--- TOOK A PHOTO SUCCESFULLY")
        
        
    }
    
    @objc func handleTap(recognizer: PhotoUploadTapGesture) {
        print(recognizer.photoTakeCase)
        self.currentPhotoTakeCase = recognizer.photoTakeCase
        switch(self.currentPhotoTakeCase) {
            case PhotoTakeCase.FIRST:
                takePhoto(recognizer)
            case PhotoTakeCase.SECOND:
                takePhoto(recognizer)
            default: print("NO PHOTO TAKE CASE WAS SET!")
        }
    }
}

class PhotoUploadTapGesture: UITapGestureRecognizer {
    var photoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
}

class PhotoDeleteTapGesture: UITapGestureRecognizer {
    let photoIdx: Int = 0
}

enum PhotoTakeCase {
    case NONE
    case FIRST
    case SECOND
}


//!
//    override func didReceiveMemoryWarning() {
//         super.didReceiveMemoryWarning()
//         // Dispose of any resources that can be recreated.
//     }
