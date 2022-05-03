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
    
    
    @IBOutlet weak var docPhotoFirstImgHolder: UIImageView!
    @IBOutlet weak var docPhotoSecondImgHolder: UIImageView!
    
    
    @IBOutlet weak var imgViewIconFirst: UIImageView!
    @IBOutlet weak var imgViewIconSecond: UIImageView!
    
    
    @IBOutlet weak var deleteFirstPhotoBtn: UIImageView!
    @IBOutlet weak var deleteSecondPhotoBtn: UIImageView!
    
    
    @IBOutlet weak var tvFirstCardTitle: UILabel!
    @IBOutlet weak var tvSecondCardTitle: UILabel!
    
    
    @IBOutlet weak var btnContinueToPreview: UIButton!
    
    
    var selectedDocType: DocType? = nil
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    var currentPhotoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
    
    
    override func viewDidLoad() {
        
        let docTypeWithData: DocTypeData = KeychainHelper.shared.getSelectedDocTypeWithData()!
        
        self.selectedDocType = DocType.docCategoryIdxToType(categoryIdx: docTypeWithData.category!)
        
        btnContinueToPreview.tintColor = UIColor(named: "borderColor")
        btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        
        deleteFirstPhotoBtn.isHidden = true
        deleteSecondPhotoBtn.isHidden = true
        
        if (self.selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = false
            
            imgViewIconFirst.isHidden = true
            imgViewIconSecond.isHidden = true
            
            tvFirstCardTitle.text = NSLocalizedString("photo_upload_title_common_forward", comment: "")
            tvSecondCardTitle.text = NSLocalizedString("photo_upload_title_common_back", comment: "")
            
            setClickListenerForFistPhotoBtn()
            setClickListenerForSecondPhotoBtn()
        }
        if (self.selectedDocType == DocType.FOREIGN_PASSPORT) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = true
            
            imgViewIconFirst.isHidden = false
            imgViewIconSecond.isHidden = true
            
            tvFirstCardTitle.text = NSLocalizedString("photo_upload_title_foreign", comment: "")
            
            if (docTypeWithData.country == "ua") {
                imgViewIconFirst.image = UIImage(imageLiteralResourceName: "doc_ua_international_passport")
            } else {
                imgViewIconFirst.isHidden = true
            }

            setClickListenerForFistPhotoBtn()
        }
        if (self.selectedDocType == DocType.ID_CARD) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = false
            
            if (docTypeWithData.country == "ua") {
                imgViewIconFirst.isHidden = false
                imgViewIconSecond.isHidden = false
                imgViewIconFirst.image = UIImage(imageLiteralResourceName: "doc_id_card_front")
                imgViewIconSecond.image = UIImage(imageLiteralResourceName: "doc_id_card_back")
            } else {
                imgViewIconFirst.isHidden = true
                imgViewIconSecond.isHidden = true
            }
            
            tvFirstCardTitle.text = NSLocalizedString("photo_upload_title_id_card_forward", comment: "")
            tvSecondCardTitle.text = NSLocalizedString("photo_upload_title_id_card_back", comment: "")
 
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
        
        if (currentPhotoTakeCase == PhotoTakeCase.FIRST) {
            imgViewIconFirst.isHidden = true
            tvFirstCardTitle.isHidden = true
            deleteFirstPhotoBtn.isHidden = false
            firstPhotoButton.isHidden = true
            firstPhotoButton.gestureRecognizers?.forEach(firstPhotoButton.removeGestureRecognizer)
            firstPhoto = image
            docPhotoFirstImgHolder.image = firstPhoto
        }
        if (currentPhotoTakeCase == PhotoTakeCase.SECOND) {
            imgViewIconSecond.isHidden = true
            tvSecondCardTitle.isHidden = true
            deleteSecondPhotoBtn.isHidden = false
            secondPhotoButton.isHidden = true
            secondPhotoButton.gestureRecognizers?.forEach(firstPhotoButton.removeGestureRecognizer)
            secondPhoto = image
            docPhotoSecondImgHolder.image = secondPhoto
        }
        
        checkPhotoCompletenessAndSetProceedClickListener()

        print("--- TOOK A PHOTO SUCCESFULLY")
    }
    
    
    func checkPhotoCompletenessAndSetProceedClickListener() {
        if (selectedDocType == DocType.FOREIGN_PASSPORT) {
            if (firstPhoto != nil) {
                prepareForNavigation(conditionsSatisfied: false)
            } else {
                let errText = NSLocalizedString("error_make_at_least_one_photo", comment: "")
                self.showToast(message: errText, seconds: 2.0)
            }
        } else if (selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
            if (firstPhoto != nil) {
                prepareForNavigation(conditionsSatisfied: true)
            } else if (secondPhoto != nil && firstPhoto == nil) {
                firstPhoto = secondPhoto
                secondPhoto = nil
                prepareForNavigation(conditionsSatisfied: true)
            } else if (secondPhoto != nil && firstPhoto != nil) {
                prepareForNavigation(conditionsSatisfied: false)
            } else {
                let errText = NSLocalizedString("error_make_at_least_one_photo", comment: "")
                self.showToast(message: errText, seconds: 2.0)
            }
        } else {
            if (firstPhoto != nil && secondPhoto != nil) {
                prepareForNavigation(conditionsSatisfied: true)
            }
        }
    }
    
    func prepareForNavigation(conditionsSatisfied: Bool) {
        btnContinueToPreview.tintColor = UIColor(named: "Default")
        btnContinueToPreview.titleLabel?.textColor = UIColor.white
        
    }
}

class PhotoUploadTapGesture: UITapGestureRecognizer {
    var photoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
}

//TODO: add photo (UImage) deletion logic
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
