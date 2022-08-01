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
    //var statusCode: Int? = nil
    var isDocCheckForced: Bool = false
    
    @IBOutlet weak var verifErrorTitleText: UILabel!
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
        self.btnContinueToCheckDoc.isHidden = true
        self.performSegue(withIdentifier: "DocPhotoVerifErrorToCheckDoc", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifErrorTitleText.text = "verif_error_desc".localized
        
        verifErrorDescrText.text = "invalid_doc_type_desc".localized
        
        btnContinueToCheckDoc.titleLabel?.textAlignment = .center
        btnContinueToCheckDoc.titleLabel?.text = "confident_in_doc_title".localized
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
            vc.isDocCheckForced = self.isDocCheckForced
        }
    }
    
}
