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
    var statusCode: Int? = nil
    
    @IBOutlet weak var verifErrorDescrText: UILabel!
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    private let viewModel = DocPhotoVerifErrorViewModel()

    @IBOutlet weak var btnContinueToCheckDoc: UIButton!
    
    @IBAction func actionReloadDocPhotos(_ sender: UIButton) {
        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
        guard let destinationVC = viewController else { return }
        self.navigationController?.popToViewController(destinationVC, animated: true)
    }
    
    @IBAction func actionResumeToDocCheck(_ sender: UIButton) {
        self.btnContinueToCheckDoc.isHidden = true //!
        self.viewModel.setDocAsPrimary(docId: self.docId!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (statusCode == 4) {
            verifErrorDescrText.text = "invalid_doc_type_desc".localized
        } else {
            verifErrorDescrText.text = "verif_error_desc".localized
        }
        
        btnContinueToCheckDoc.titleLabel?.textAlignment = .center
        btnContinueToCheckDoc.titleLabel?.text = "confident_in_doc_title".localized
        
        viewModel.didReceiveConfirmResponse = {
            self.performSegue(withIdentifier: "DocPhotoVerifErrorToCheckDoc", sender: nil)
        }
        
        viewModel.showAlertClosure = {
            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
            self.showToast(message: errText, seconds: 2.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DocPhotoVerifErrorToCheckDoc") {
            let vc = segue.destination as! CheckDocInfoViewController
            if (self.docId == nil) {
                let errText = "Error: Cannot find document id for navigation!"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                vc.docId = self.docId
            }
            vc.firstPhoto = self.firstPhoto
            if (self.secondPhoto != nil) {
                vc.secondPhoto = self.secondPhoto
            }
        }
    }
    
}
