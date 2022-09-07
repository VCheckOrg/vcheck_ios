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
        
    @IBOutlet weak var continueButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var parentCardHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var frontSideDocTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var backSideDocTitleConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var firstPhotoCard: SmallRoundedView!
    @IBOutlet weak var secondPhotoCard: SmallRoundedView!
    
    @IBOutlet weak var firstPhotoButton: SmallRoundedView!
    @IBOutlet weak var secondPhotoButton: SmallRoundedView!
    
    @IBOutlet weak var docPhotoFirstImgHolder: UIImageView!
    @IBOutlet weak var docPhotoSecondImgHolder: UIImageView!
    
    @IBOutlet weak var imgViewIconFirst: UIImageView!
    @IBOutlet weak var imgViewIconSecond: UIImageView!
    
    @IBOutlet weak var deleteFirstPhotoBtn: UIImageView!
    @IBOutlet weak var deleteSecondPhotoBtn: UIImageView!
    
    @IBOutlet weak var tvFirstCardTitle: UILabel!
    @IBOutlet weak var tvSecondCardTitle: UILabel!
    
    @IBOutlet weak var btnContinueToPreview: UIButton!
    
    @IBAction func backToInstr(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    var selectedDocType: DocType? = nil
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    var currentPhotoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
    
    
    override func viewDidLoad() {
        
        let docTypeWithData: DocTypeData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()!
        
        self.selectedDocType = DocType.docCategoryIdxToType(categoryIdx: docTypeWithData.category!)
        
        self.btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
        self.btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        self.btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        self.btnContinueToPreview.setTitle("proceed".localized, for: .disabled)
        self.btnContinueToPreview.setTitle("proceed".localized, for: .normal)
        
        self.deleteFirstPhotoBtn.isHidden = true
        self.deleteSecondPhotoBtn.isHidden = true
        
        self.tvFirstCardTitle.isHidden = false
        self.tvSecondCardTitle.isHidden = false
        
        self.firstPhotoButton.isHidden = false
        self.secondPhotoButton.isHidden = false
        
        if (self.selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = false
            
            imgViewIconFirst.isHidden = true
            imgViewIconSecond.isHidden = true
            
            frontSideDocTitleConstraint.constant = 16
            backSideDocTitleConstraint.constant = 16
            
            tvFirstCardTitle.text = "photo_upload_title_common_forward".localized
            tvSecondCardTitle.text = "photo_upload_title_common_back".localized
            
            setClickListenerForFirstPhotoBtn()
            setClickListenerForSecondPhotoBtn()
        }
        if (self.selectedDocType == DocType.FOREIGN_PASSPORT) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = true
            
            imgViewIconFirst.isHidden = false
            imgViewIconSecond.isHidden = true
            
            tvFirstCardTitle.text = "photo_upload_title_foreign".localized
            
            if (docTypeWithData.country == "ua") {
                imgViewIconFirst.image = UIImage.init(named: "doc_ua_international_passport")
            } else {
                imgViewIconFirst.isHidden = true
                frontSideDocTitleConstraint.constant = 16
            }
            
            parentCardHeightConstraint.constant = parentCardHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            continueButtonTopConstraint.constant = continueButtonTopConstraint.constant - 250 // * - 2nd (missing) card height - 20
            
            self.secondPhotoButton.isHidden = true

            setClickListenerForFirstPhotoBtn()
        }
        if (self.selectedDocType == DocType.ID_CARD) {
            
            firstPhotoCard.isHidden = false
            secondPhotoCard.isHidden = false
            
            if (docTypeWithData.country == "ua") {
                imgViewIconFirst.isHidden = false
                imgViewIconSecond.isHidden = false
                imgViewIconFirst.image = UIImage.init(named: "doc_id_card_front")
                imgViewIconSecond.image = UIImage.init(named: "doc_id_card_back")
            } else {
                imgViewIconFirst.isHidden = true
                imgViewIconSecond.isHidden = true
                
                frontSideDocTitleConstraint.constant = 16
                backSideDocTitleConstraint.constant = 16
            }
            
            tvFirstCardTitle.text = "photo_upload_title_id_card_forward".localized
            tvSecondCardTitle.text = "photo_upload_title_id_card_back".localized
 
            setClickListenerForFirstPhotoBtn()
            setClickListenerForSecondPhotoBtn()
        }
    }
    
    func setClickListenerForFirstPhotoBtn() {
        let tapped1 = PhotoUploadTapGesture.init(target: self, action: #selector(handlePhotoCameraTap))
        tapped1.photoTakeCase = PhotoTakeCase.FIRST
        tapped1.numberOfTapsRequired = 1
        self.firstPhotoButton.addGestureRecognizer(tapped1)
    }
    
    func setClickListenerForSecondPhotoBtn() {
        let tapped2 = PhotoUploadTapGesture.init(target: self, action: #selector(handlePhotoCameraTap))
        tapped2.photoTakeCase = PhotoTakeCase.SECOND
        tapped2.numberOfTapsRequired = 1
        self.secondPhotoButton.addGestureRecognizer(tapped2)
    }
    
    func setClickListenerForFistDeletionBtn() {
        let tapped1 = PhotoDeleteTapGesture.init(target: self, action: #selector(handlePhotoDeleteTap))
        tapped1.photoIdx = 1
        tapped1.numberOfTapsRequired = 1
        self.deleteFirstPhotoBtn.addGestureRecognizer(tapped1)
    }
    
    func setClickListenerForSecondDeletionBtn() {
        let tapped2 = PhotoDeleteTapGesture.init(target: self, action: #selector(handlePhotoDeleteTap))
        tapped2.photoIdx = 2
        tapped2.numberOfTapsRequired = 1
        self.deleteSecondPhotoBtn.addGestureRecognizer(tapped2)
    }
    
    @objc func handlePhotoCameraTap(recognizer: PhotoUploadTapGesture) {
        print(recognizer.photoTakeCase)
        self.currentPhotoTakeCase = recognizer.photoTakeCase
        switch(self.currentPhotoTakeCase) {
            case PhotoTakeCase.FIRST:
                takePhoto(recognizer)
            case PhotoTakeCase.SECOND:
                takePhoto(recognizer)
            default: print("VCheckSDK: No photo take case was set")
        }
    }
    
    @objc func takePhoto(_ sender: UITapGestureRecognizer) {
        var sourceType: UIImagePickerController.SourceType = .camera
        if (UIDevice.isSimulator) {
            sourceType = .photoLibrary
        } else {
            sourceType = .camera
        }
        let vc = UIImagePickerController()
        vc.sourceType = sourceType
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("VCheckSDK - Error: No image found with UIImagePickerController")
            return
        }
        
        if (currentPhotoTakeCase == PhotoTakeCase.FIRST) {
            
            imgViewIconFirst.isHidden = true
            tvFirstCardTitle.isHidden = true
            
            deleteFirstPhotoBtn.isHidden = false
            setClickListenerForFistDeletionBtn()
            
            firstPhotoButton.isHidden = true
            firstPhotoButton.gestureRecognizers?.forEach(firstPhotoButton.removeGestureRecognizer)
            firstPhoto = image
            docPhotoFirstImgHolder.image = firstPhoto
        }
        if (currentPhotoTakeCase == PhotoTakeCase.SECOND) {
            imgViewIconSecond.isHidden = true
            tvSecondCardTitle.isHidden = true
            
            deleteSecondPhotoBtn.isHidden = false
            setClickListenerForSecondDeletionBtn()
            
            secondPhotoButton.isHidden = true
            secondPhotoButton.gestureRecognizers?.forEach(secondPhotoButton.removeGestureRecognizer)
            secondPhoto = image
            docPhotoSecondImgHolder.image = secondPhoto
        }
        
        checkPhotoCompletenessAndSetProceedClickListener()
    }
    
    @objc func handlePhotoDeleteTap(recognizer: PhotoDeleteTapGesture) {
        
        switch(recognizer.photoIdx) {
            case 1:
                imgViewIconFirst.isHidden = false
                tvFirstCardTitle.isHidden = false
                deleteFirstPhotoBtn.isHidden = true
                deleteFirstPhotoBtn.gestureRecognizers?.forEach(deleteFirstPhotoBtn.removeGestureRecognizer)
                firstPhotoButton.isHidden = false
                docPhotoFirstImgHolder.image = nil
                firstPhoto = nil
                setClickListenerForFirstPhotoBtn()
                checkPhotoCompletenessAndSetProceedClickListener()
            case 2:
                imgViewIconSecond.isHidden = false
                tvSecondCardTitle.isHidden = false
                deleteSecondPhotoBtn.isHidden = true
                deleteSecondPhotoBtn.gestureRecognizers?.forEach(deleteSecondPhotoBtn.removeGestureRecognizer)
                secondPhotoButton.isHidden = false
                docPhotoSecondImgHolder.image = nil
                secondPhoto = nil
                setClickListenerForSecondPhotoBtn()
                checkPhotoCompletenessAndSetProceedClickListener()
            default:
                checkPhotoCompletenessAndSetProceedClickListener()
        }
    }

    func checkPhotoCompletenessAndSetProceedClickListener() {
        if (selectedDocType == DocType.FOREIGN_PASSPORT) {
            if (firstPhoto != nil) {
                prepareForNavigation(resetSecondPhoto: false)
            } else {
                showMinPhotosError()
            }
        } else if (selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
            if (firstPhoto != nil) {
                prepareForNavigation(resetSecondPhoto: false)
            } else if (secondPhoto != nil && firstPhoto != nil) {
                prepareForNavigation(resetSecondPhoto: true)
            } else if (secondPhoto != nil && firstPhoto == nil) {
                showBothPhotosNeededError()
            } else {
                showMinPhotosError()
            }
        } else {
            if (firstPhoto != nil && secondPhoto != nil) {
                prepareForNavigation(resetSecondPhoto: true)
            } else {
                showBothPhotosNeededError()
            }
        }
    }
    
    func showBothPhotosNeededError() {
        btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
        btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        let errText = "error_make_two_photos".localized
        self.showToast(message: errText, seconds: 1.3)
    }
    
    func showMinPhotosError() {
        btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
        btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        let errText = "error_make_at_least_one_photo".localized
        self.showToast(message: errText, seconds: 1.3)
    }
    
    func prepareForNavigation(resetSecondPhoto: Bool) {
        if let buttonColor = VCheckSDK.shared.buttonsColorHex {
            btnContinueToPreview.tintColor = buttonColor.hexToUIColor()
        } else {
            btnContinueToPreview.tintColor = UIColor(named: "Default", in: InternalConstants.bundle, compatibleWith: nil)
        }
        btnContinueToPreview.titleLabel?.textColor = UIColor.white
        
        let tapGesture = NavGestureRecognizer.init(target: self, action: #selector(navigateToCheckScreen(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.resetSecondPhoto = resetSecondPhoto
        btnContinueToPreview.addGestureRecognizer(tapGesture)
    }
    
    @objc func navigateToCheckScreen(_ sender: NavGestureRecognizer) {
        
        self.performSegue(withIdentifier: "TakeToCheckPhoto", sender: nil)
        
        self.firstPhoto = nil
        self.secondPhoto = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TakeToCheckPhoto") {
            let vc = segue.destination as! CheckDocPhotoViewController
            vc.firstPhoto = self.firstPhoto
            if (self.secondPhoto != nil) {
                vc.secondPhoto = self.secondPhoto
            }
            vc.isFromSegmentation = false
            
            vc.onRepeatBlock = { result in
                                
                self.currentPhotoTakeCase = PhotoTakeCase.NONE
                
                if (self.selectedDocType == DocType.FOREIGN_PASSPORT) {
                    self.parentCardHeightConstraint.constant = self.parentCardHeightConstraint.constant + 250
                    self.continueButtonTopConstraint.constant = self.continueButtonTopConstraint.constant + 250
                }
                
                self.firstPhoto = nil
                self.secondPhoto = nil
        
                self.docPhotoFirstImgHolder.image = nil
                self.docPhotoSecondImgHolder.image = nil
                
                self.viewDidLoad()
                self.checkPhotoCompletenessAndSetProceedClickListener()
            }
        }
    }
}

class PhotoUploadTapGesture: UITapGestureRecognizer {
    var photoTakeCase: PhotoTakeCase = PhotoTakeCase.NONE
}

class PhotoDeleteTapGesture: UITapGestureRecognizer {
    var photoIdx: Int = 0
}

class NavGestureRecognizer: UITapGestureRecognizer {
    var resetSecondPhoto: Bool = false
}

enum PhotoTakeCase {
    case NONE
    case FIRST
    case SECOND
}
