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
        
        activityIndicatorStop()
        
        imgViewPhotoFirst.image = firstPhoto
        
        let zoomFirstPhotoTap = UITapGestureRecognizer(target: self, action: #selector(zoomFirstPhoto(_:)))
        zoomFirstPhotoBtn.addGestureRecognizer(zoomFirstPhotoTap)
        
        if (secondPhoto != nil) {
            secondPhotoCard.isHidden = false
            imgViewPhotoSecond.image = secondPhoto
            
            let zoomSecondPhotoTap = UITapGestureRecognizer(target: self, action: #selector(zoomSecondPhoto(_:)))
            zoomSecondPhotoBtn.addGestureRecognizer(zoomSecondPhotoTap)
        } else {
            secondPhotoCard.isHidden = true
            
            remakeBtnVerticalConstraint.constant = 86
            confirmBtnVerticalConstraint.constant = 160
            
            tvLoadingTopConstraint.constant = 80
            uplSpinnerTopConstraint.constant = 160
        }
                
        viewModel.didReceiveDocUploadResponse = {
            self.activityIndicatorStop()
            
            print("RECEIVED PHOTO UPLOAD RESPONSE! ::: \(String(describing: self.viewModel.uploadResponse))")
            
            //TODO: handle doc upload response w/codes
            
            if (self.viewModel.uploadResponse?.status != nil && self.viewModel.uploadResponse?.status != 0) {
                let errText = "\(codeIdxToVerificationCode(codeIdx: (self.viewModel.uploadResponse?.status)!))"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                
                self.navigateToDocInfoScreen()
            }
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
            if (self.viewModel.uploadResponse?.document == nil) {
                let errText = "Error: Cannot find document id for navigation!"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                vc.docId = self.viewModel.uploadResponse?.document
            }
        }
        if (segue.identifier == "CheckPhotoToZoom") {
            let vc = segue.destination as! ZoomedDocPhotoViewController
            vc.photoToZoom = sender as! UIImage?
        }
    }
    
    func moveToChooseDocTypeViewController() {
        self.dismiss(animated: true) //!
                        
//        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
//        guard let destinationVC = viewController else { return }
//        self.navigationController?.popToViewController(destinationVC, animated: true)
//            if let firstViewController = self.navigationController?.viewControllers[2] {
//                self.navigationController?.popToViewController(firstViewController, animated: true)
//            }
    }
    
    
    @objc func zoomFirstPhoto(_ sender: NavGestureRecognizer) {
        self.performSegue(withIdentifier: "CheckPhotoToZoom", sender: self.firstPhoto)
    }
    
    @objc func zoomSecondPhoto(_ sender: NavGestureRecognizer) {
        if (secondPhoto != nil) {
            self.performSegue(withIdentifier: "CheckPhotoToZoom", sender: self.secondPhoto)
        }
    }
    
    
    private func activityIndicatorStart() {
        remakeDocPhotosBtn.isHidden = true
        confirmUploadPhotosBtn.isHidden = true
        tvLoadingDescl.isHidden = false
        tvLoadingDescl.text = NSLocalizedString("photo_loaing_wait_discl", comment: "")
        photosUploadingSpinner.isHidden = false
        photosUploadingSpinner.startAnimating()
    }
    
    private func activityIndicatorStop() {
        tvLoadingDescl.isHidden = true
        photosUploadingSpinner.stopAnimating()
        photosUploadingSpinner.isHidden = true
        remakeDocPhotosBtn.isHidden = false
        confirmUploadPhotosBtn.isHidden = false
    }
}
