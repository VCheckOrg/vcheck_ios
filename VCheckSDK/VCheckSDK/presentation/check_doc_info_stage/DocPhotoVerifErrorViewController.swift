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
    
    @IBOutlet weak var verifErrorTitleText: UILabel!
    @IBOutlet weak var verifErrorDescrText: UILabel!
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    private let viewModel = DocPhotoVerifErrorViewModel()

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
        
        self.verifErrorTitleText.text = "verif_error_desc".localized
        
        self.verifErrorDescrText.text = "invalid_doc_type_desc".localized
        
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
//            vc.firstPhoto = self.firstPhoto
//            if (self.secondPhoto != nil) {
//                vc.secondPhoto = self.secondPhoto
//            }
            vc.isDocCheckForced = self.isDocCheckForced
        }
    }
    
}
