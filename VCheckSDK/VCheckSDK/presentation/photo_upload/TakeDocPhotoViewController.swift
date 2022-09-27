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
        super.viewDidLoad()
        
        self.initOrRefreshState()
    }
    
    func initOrRefreshState() {
        
        if let docTypeWithData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData() {
            
            if (docTypeWithData.country != VCheckSDK.shared.getSelectedCountryCode()) {
                VCheckSDK.shared.setSelectedCountryCode(code: docTypeWithData.country!)
            }
        
            self.selectedDocType = DocType.docCategoryIdxToType(categoryIdx: docTypeWithData.category!)
            
            self.btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
            self.btnContinueToPreview.titleLabel?.textColor = UIColor.gray
            self.btnContinueToPreview.gestureRecognizers?.forEach(self.btnContinueToPreview.removeGestureRecognizer)
            self.btnContinueToPreview.setTitle("proceed".localized, for: .disabled)
            self.btnContinueToPreview.setTitle("proceed".localized, for: .normal)
            
            self.deleteFirstPhotoBtn.isHidden = true
            self.deleteSecondPhotoBtn.isHidden = true
            
            self.tvFirstCardTitle.isHidden = false
            self.tvSecondCardTitle.isHidden = false
            
            self.firstPhotoButton.isHidden = false
            self.secondPhotoButton.isHidden = false
            
            if (self.selectedDocType == DocType.INNER_PASSPORT_OR_COMMON) {
                self.setUIForInnerPassportOrCommon(docTypeWithData: docTypeWithData)
            }
            if (self.selectedDocType == DocType.FOREIGN_PASSPORT) {
                self.setUIForForeignPassport(docTypeWithData: docTypeWithData)
            }
            if (self.selectedDocType == DocType.ID_CARD) {
                self.setUIForIDCard(docTypeWithData: docTypeWithData)
            }
        } else {
            print("VCheck SDK - error: no Selected Doc Type With Data provided for take-photo screen")
        }
    }
    
    
    private func docHasOnePage(docTypeData: DocTypeData) -> Bool {
        return docTypeData.maxPagesCount == 1 && docTypeData.minPagesCount == 1
    }

    private func docHasOneRequiredPage(docTypeData: DocTypeData) -> Bool {
        return docTypeData.minPagesCount == 1 && docTypeData.maxPagesCount! > 1
    }

    private func docHasTwoOrMorePagesRequired(docTypeData: DocTypeData) -> Bool {
        return docTypeData.maxPagesCount! > 1 && docTypeData.minPagesCount! > 1
    }
    
    
    private func setUIForIDCard(docTypeWithData: DocTypeData) {
        
        if (docHasOnePage(docTypeData: docTypeWithData)) {
            
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = true
            
            if (docTypeWithData.country == "ua") {
                self.imgViewIconFirst.isHidden = false
                self.imgViewIconSecond.isHidden = true
                self.imgViewIconFirst.image = UIImage.init(named: "doc_id_card_front")
            } else {
                self.imgViewIconFirst.isHidden = true
                self.imgViewIconSecond.isHidden = true
                self.frontSideDocTitleConstraint.constant = 16
            }
            
            self.parentCardHeightConstraint.constant = self.parentCardHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            self.continueButtonTopConstraint.constant = self.continueButtonTopConstraint.constant - 250 // * - 2nd (missing) card height - 20
            
            self.tvFirstCardTitle.text = "photo_upload_title_id_card_forward".localized

            self.setClickListenerForFirstPhotoBtn()
            
        } else {
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = false
            
            if (docTypeWithData.country == "ua") {
                self.imgViewIconFirst.isHidden = false
                self.imgViewIconSecond.isHidden = false
                self.imgViewIconFirst.image = UIImage.init(named: "doc_id_card_front")
                self.imgViewIconSecond.image = UIImage.init(named: "doc_id_card_back")
            } else {
                self.imgViewIconFirst.isHidden = true
                self.imgViewIconSecond.isHidden = true
                
                self.frontSideDocTitleConstraint.constant = 16
                self.backSideDocTitleConstraint.constant = 16
            }
            
            self.tvFirstCardTitle.text = "photo_upload_title_id_card_forward".localized
            self.tvSecondCardTitle.text = "photo_upload_title_id_card_back".localized

            self.setClickListenerForFirstPhotoBtn()
            self.setClickListenerForSecondPhotoBtn()
        }
        
    }
    
    private func setUIForInnerPassportOrCommon(docTypeWithData: DocTypeData) {
        
        if (docHasOnePage(docTypeData: docTypeWithData)) {
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = true
            
            self.imgViewIconFirst.isHidden = true
            self.imgViewIconSecond.isHidden = true
            
            self.frontSideDocTitleConstraint.constant = 16
            
            self.parentCardHeightConstraint.constant = self.parentCardHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            self.continueButtonTopConstraint.constant = self.continueButtonTopConstraint.constant - 250 // * - 2nd (missing) card height - 20
            
            self.tvFirstCardTitle.text = "photo_upload_title_common_forward".localized
            
            self.setClickListenerForFirstPhotoBtn()
        } else {
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = false
            
            self.imgViewIconFirst.isHidden = true
            self.imgViewIconSecond.isHidden = true
            
            self.frontSideDocTitleConstraint.constant = 16
            self.backSideDocTitleConstraint.constant = 16
            
            self.tvFirstCardTitle.text = "photo_upload_title_common_forward".localized
            self.tvSecondCardTitle.text = "photo_upload_title_common_back".localized
            
            self.setClickListenerForFirstPhotoBtn()
            self.setClickListenerForSecondPhotoBtn()
        }
    }
    
    private func setUIForForeignPassport(docTypeWithData: DocTypeData) {
        
        if (docHasOnePage(docTypeData: docTypeWithData)) {
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = true
            
            self.imgViewIconFirst.isHidden = false
            self.imgViewIconSecond.isHidden = true
            
            self.tvFirstCardTitle.text = "photo_upload_title_foreign".localized
            
            if (docTypeWithData.country == "ua") {
                self.imgViewIconFirst.image = UIImage.init(named: "doc_ua_international_passport")
            } else {
                self.imgViewIconFirst.isHidden = true
                self.frontSideDocTitleConstraint.constant = 16
            }
            
            self.parentCardHeightConstraint.constant = self.parentCardHeightConstraint.constant - 250 // * - 2nd (missing) card height - 20
            self.continueButtonTopConstraint.constant = self.continueButtonTopConstraint.constant - 250 // * - 2nd (missing) card height - 20
            
            self.secondPhotoButton.isHidden = true

            self.setClickListenerForFirstPhotoBtn()
            
        } else {
            self.firstPhotoCard.isHidden = false
            self.secondPhotoCard.isHidden = false
            
            self.imgViewIconFirst.isHidden = false
            self.imgViewIconSecond.isHidden = false
            
            self.tvFirstCardTitle.text = "photo_upload_title_common_forward".localized
            self.tvSecondCardTitle.text = "photo_upload_title_common_back".localized
            
            if (docTypeWithData.country == "ua") {
                self.imgViewIconFirst.image = UIImage.init(named: "doc_ua_international_passport")
                self.imgViewIconSecond.image = UIImage.init(named: "doc_ua_international_passport")
            } else {
                self.imgViewIconFirst.isHidden = true
                self.imgViewIconSecond.isHidden = true
                self.frontSideDocTitleConstraint.constant = 16
                self.backSideDocTitleConstraint.constant = 16
            }
            self.setClickListenerForFirstPhotoBtn()
            self.setClickListenerForSecondPhotoBtn()
        }
    }
    
    
    private func setClickListenerForFirstPhotoBtn() {
        let tapped1 = PhotoUploadTapGesture.init(target: self, action: #selector(handlePhotoCameraTap))
        tapped1.photoTakeCase = PhotoTakeCase.FIRST
        tapped1.numberOfTapsRequired = 1
        self.firstPhotoButton.addGestureRecognizer(tapped1)
    }
    
    private func setClickListenerForSecondPhotoBtn() {
        let tapped2 = PhotoUploadTapGesture.init(target: self, action: #selector(handlePhotoCameraTap))
        tapped2.photoTakeCase = PhotoTakeCase.SECOND
        tapped2.numberOfTapsRequired = 1
        self.secondPhotoButton.addGestureRecognizer(tapped2)
    }
    
    private func setClickListenerForFistDeletionBtn() {
        let tapped1 = PhotoDeleteTapGesture.init(target: self, action: #selector(handlePhotoDeleteTap))
        tapped1.photoIdx = 1
        tapped1.numberOfTapsRequired = 1
        self.deleteFirstPhotoBtn.addGestureRecognizer(tapped1)
    }
    
    private func setClickListenerForSecondDeletionBtn() {
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

    private func checkPhotoCompletenessAndSetProceedClickListener() {
        if let docTypeWithData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData() {
            if (docHasOnePage(docTypeData: docTypeWithData) || docHasOneRequiredPage(docTypeData: docTypeWithData)) {
                if (firstPhoto != nil) {
                    prepareForNavigation(resetSecondPhoto: false)
                } else {
                    self.showMinPhotosError()
                }
            } else if (docHasTwoOrMorePagesRequired(docTypeData: docTypeWithData)) {
                if (secondPhoto != nil && firstPhoto != nil) {
                    prepareForNavigation(resetSecondPhoto: true)
                } else {
                    self.showBothPhotosNeededError()
                }
            }
        } else {
            print("VCheck SDK - error: no Selected Doc Type With Data provided for take-photo screen")
        }
    }
    
    private func showBothPhotosNeededError() {
        btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
        btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        let errText = "error_make_two_photos".localized
        self.showToast(message: errText, seconds: 1.3)
    }
    
    private func showMinPhotosError() {
        btnContinueToPreview.tintColor = UIColor(named: "borderColor", in: InternalConstants.bundle, compatibleWith: nil)
        btnContinueToPreview.titleLabel?.textColor = UIColor.gray
        btnContinueToPreview.gestureRecognizers?.forEach(btnContinueToPreview.removeGestureRecognizer)
        let errText = "error_make_at_least_one_photo".localized
        self.showToast(message: errText, seconds: 1.3)
    }
    
    private func prepareForNavigation(resetSecondPhoto: Bool) {
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
                
                if let docTypeWithData = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData() {
                    if (self.docHasOnePage(docTypeData: docTypeWithData)) {
                        self.parentCardHeightConstraint.constant = self.parentCardHeightConstraint.constant + 250
                        self.continueButtonTopConstraint.constant = self.continueButtonTopConstraint.constant + 250
                    }
                } else {
                    print("VCheck SDK - error: no Selected Doc Type With Data provided for take-photo screen")
                }
                
                self.firstPhoto = nil
                self.secondPhoto = nil
        
                self.docPhotoFirstImgHolder.image = nil
                self.docPhotoSecondImgHolder.image = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250) ) {
                    self.initOrRefreshState()
                    self.checkPhotoCompletenessAndSetProceedClickListener()
                }
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
