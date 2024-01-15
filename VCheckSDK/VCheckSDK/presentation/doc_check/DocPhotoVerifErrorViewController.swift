//
//  DocPhotoVerifErrorViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 12.05.2022.
//

import Foundation
import UIKit


class DocPhotoVerifErrorViewController : UIViewController {
    
    var docId: Int? = nil
    var isDocCheckForced: Bool = false
    
    var errorCode: DocumentVerificationCode? = nil
    
    @IBOutlet weak var verifErrorTitleText: UILabel!
    @IBOutlet weak var verifErrorDescrText: UILabel!

    @IBOutlet weak var btnContinueToCheckDoc: UIButton!
    
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBAction func actionReloadDocPhotos(_ sender: UIButton) {
        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
        guard let destinationVC = viewController else { return }
        self.navigationController?.popToViewController(destinationVC, animated: true)
    }
    
    @IBAction func actionResumeToDocCheck(_ sender: UIButton) {
        self.btnContinueToCheckDoc.isHidden = true
        self.performSegue(withIdentifier: "DocPhotoVerifErrorToCheckDoc", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retryBtn.setTitle("retry".localized, for: .normal)
        
        self.verifErrorTitleText.text = getCodeStringTitleResource(code: errorCode)
        self.verifErrorDescrText.text = getCodeStringDescriptionResource(code: errorCode)
        
        self.btnContinueToCheckDoc.setTitle("confident_in_doc_title".localized, for: .normal)
        self.btnContinueToCheckDoc.titleLabel?.text = "confident_in_doc_title".localized
        self.btnContinueToCheckDoc.titleLabel?.textAlignment = .center
        self.btnContinueToCheckDoc.titleLabel?.textColor = UIColor.white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DocPhotoVerifErrorToCheckDoc") {
            let vc = segue.destination as! CheckDocInfoViewController
            if (self.docId == nil) {
                let errText = "Error: Cannot receive document id! Need to take manual photos"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                vc.docId = self.docId
            }
            vc.isDocCheckForced = self.isDocCheckForced
        }
    }
    
    private func getCodeStringTitleResource(code: DocumentVerificationCode?) -> String {
        switch code {
        case .VERIFICATION_NOT_INITIALIZED:
            return "doc_verif_default_title".localized
        case .USER_INTERACTED_COMPLETED:
            return "doc_verif_default_title".localized
        case .STAGE_NOT_FOUND:
            return "doc_verif_default_title".localized
        case .INVALID_STAGE_TYPE:
            return "doc_verif_default_title".localized
        case .PRIMARY_DOCUMENT_EXISTS:
            return "doc_verif_primary_already_exists_title".localized
        case .UPLOAD_ATTEMPTS_EXCEEDED:
            return "doc_verif_upload_attempts_exceeded_title".localized
        case .INVALID_DOCUMENT_TYPE:
            return "doc_verif_invalid_document_type_title".localized
        case .INVALID_PAGES_COUNT:
            return "doc_verif_invalid_pages_count_title".localized
        case .INVALID_FILES:
            return "doc_verif_invalid_files_title".localized
        case .PHOTO_TOO_LARGE:
            return "doc_verif_invalid_files_title".localized
        case .PARSING_ERROR:
            return "doc_verif_not_scanned_title".localized
        case .INVALID_PAGE:
            return "doc_verif_invalid_page_title".localized
        case .FRAUD:
            return "doc_verif_fraud_title".localized
        case .BLUR:
            return "doc_verif_blur_title".localized
        case .PRINT:
            return "doc_verif_print_title".localized
        default:
            return "Document Verification Error"
        }
    }
    
    private func getCodeStringDescriptionResource(code: DocumentVerificationCode?) -> String {
        switch code {
        case .VERIFICATION_NOT_INITIALIZED:
            return "doc_verif_default_text".localized
        case .USER_INTERACTED_COMPLETED:
            return "doc_verif_default_text".localized
        case .STAGE_NOT_FOUND:
            return "doc_verif_default_text".localized
        case .INVALID_STAGE_TYPE:
            return "doc_verif_default_text".localized
        case .PRIMARY_DOCUMENT_EXISTS:
            return "doc_verif_primary_already_exists_text".localized
        case .UPLOAD_ATTEMPTS_EXCEEDED:
            return "doc_verif_upload_attempts_exceeded_text".localized
        case .INVALID_DOCUMENT_TYPE:
            return "doc_verif_invalid_document_type_text".localized
        case .INVALID_PAGES_COUNT:
            return "doc_verif_invalid_pages_count_text".localized
        case .INVALID_FILES:
            return "doc_verif_invalid_files_text".localized
        case .PHOTO_TOO_LARGE:
            return "doc_verif_invalid_files_text".localized
        case .PARSING_ERROR:
            return "doc_verif_not_scanned_text".localized
        case .INVALID_PAGE:
            return "doc_verif_invalid_page_text".localized
        case .FRAUD:
            return "doc_verif_fraud_text".localized
        case .BLUR:
            return "doc_verif_blur_text".localized
        case .PRINT:
            return "doc_verif_print_text".localized
        default:
            return "Document Verification Error"
        }
    }
}
