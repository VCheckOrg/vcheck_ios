//
//  CheckDocPhotoViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocPhotoViewController : UIViewController {
    
    private let viewModel = CheckDocPhotoViewModel()
    
    var firstPhoto: UIImage? = nil
    var secondPhoto: UIImage? = nil
    
    @IBOutlet weak var secondPhotoCard: RoundedView!
    
    @IBOutlet weak var imgViewPhotoFirst: UIImageView!
    @IBOutlet weak var imgViewPhotoSecond: UIImageView!
    
    @IBOutlet weak var remakeDocPhotosBtn: RoundedView!
    @IBOutlet weak var confirmUploadPhotosBtn: UIButton!
    
    @IBOutlet weak var zoomFirstPhotoBtn: UIImageView!
    @IBOutlet weak var zoomSecondPhotoBtn: UIImageView!
    
    @IBOutlet weak var confirmBtnVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var remakeBtnVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tvLoadingDescl: UITextView!
    @IBOutlet weak var photosUploadingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var tvLoadingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var uplSpinnerTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        
        imgViewPhotoFirst.image = firstPhoto
        
        if (secondPhoto != nil) {
            secondPhotoCard.isHidden = false
            imgViewPhotoSecond.image = secondPhoto
        } else {
            secondPhotoCard.isHidden = true
            
            remakeBtnVerticalConstraint.constant = 100
            confirmBtnVerticalConstraint.constant = 200
            
            tvLoadingTopConstraint.constant = 100
            uplSpinnerTopConstraint.constant = 200
        }
        
        //self.activityIndicatorStart()
        
        viewModel.didReceiveDocUploadResponse = {
            //TODO: handle doc upload response w/codes
        }
        
        viewModel.updateLoadingStatus = {
            if (self.viewModel.isLoading == true) {
                self.activityIndicatorStart()
            } else {
                self.activityIndicatorStop()
            }
        }
        
        viewModel.showAlertClosure = {
            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
            self.showToast(message: errText, seconds: 2.0)
        }
        
        let replacePhotosTap = UITapGestureRecognizer(target: self, action: #selector(replacePhotoClicked(_:)))
        let uploadPhotosTap = UITapGestureRecognizer(target: self, action: #selector(performDocUploadRequest(_:)))
        
        remakeDocPhotosBtn.addGestureRecognizer(replacePhotosTap)
        confirmUploadPhotosBtn.addGestureRecognizer(uploadPhotosTap)
    }
    
    
    
    @objc func replacePhotoClicked(_ sender: NavGestureRecognizer) {
        firstPhoto = nil
        secondPhoto = nil
        
        moveToChooseDocTypeViewController()
    }
    
    @objc func performDocUploadRequest(_ sender: NavGestureRecognizer) {
        viewModel.sendDocForVerifUpload(photo1: self.firstPhoto!, photo2: self.secondPhoto)
    }
    
    func navigateToDocInfoScreen() {
        self.performSegue(withIdentifier: "DocPhotosPreviewToCheckDocInfo", sender: nil)
        
        firstPhoto = nil
        secondPhoto = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DocPhotosPreviewToCheckDocInfo") {
            let vc = segue.destination as! CheckDocInfoViewController
            vc.firstPhoto = self.firstPhoto
            if (self.secondPhoto != nil) {
                vc.secondPhoto = self.secondPhoto
            }
        }
    }
    
    func moveToChooseDocTypeViewController() {
        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
        guard let destinationVC = viewController else { return }
        self.navigationController?.popToViewController(destinationVC, animated: true)
    }
    
    private func activityIndicatorStart() {
        //self.spinner.startAnimating()
    }
    
    private func activityIndicatorStop() {
        //self.spinner.stopAnimating()
    }
}
