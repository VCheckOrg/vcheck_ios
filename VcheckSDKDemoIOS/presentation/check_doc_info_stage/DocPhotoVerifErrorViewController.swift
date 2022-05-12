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
    
    private let viewModel = DocPhotoVerifErrorViewModel()

    @IBOutlet weak var btnContinueToCheckDoc: UIButton!
    
    @IBAction func actionReloadDocPhotos(_ sender: UIButton) {
        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
        guard let destinationVC = viewController else { return }
        self.navigationController?.popToViewController(destinationVC, animated: true)
    }
    
    @IBAction func actionResumeToDocCheck(_ sender: UIButton) {
        self.viewModel.setDocAsPrimary(docId: self.docId!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnContinueToCheckDoc.titleLabel?.textAlignment = .center
        
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
        }
    }
    
}
