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
    
    @IBOutlet weak var tvLoadingDescl: UILabel!
    
    @IBOutlet weak var photosUploadingSpinner: UIActivityIndicatorView!
    
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

            uplSpinnerTopConstraint.constant = 400
            
        } else {
            secondPhotoCard.isHidden = true
            
            remakeBtnVerticalConstraint.constant = 86
            confirmBtnVerticalConstraint.constant = 160
                    
            uplSpinnerTopConstraint.constant = 130

        }
                
        viewModel.didReceiveDocUploadResponse = {
            self.handleDocUploadResponse()
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
    
    func handleDocUploadResponse() {
        self.activityIndicatorStop()
        
        print("RECEIVED PHOTO UPLOAD RESPONSE! ::: \(String(describing: self.viewModel.uploadResponse))")
        
        //TODO: handle doc upload response w/codes
        
        if (self.viewModel.uploadResponse?.errorCode != nil && self.viewModel.uploadResponse?.errorCode != 0) {
            self.showToast(message: "Error: [\(String(describing: self.viewModel.uploadResponse?.errorCode))]", seconds: 3.0)
        } else {
            if (self.viewModel.uploadResponse?.data != nil) {
                self.navigateToDocInfoScreen()
            } else {
                self.showToast(message: "Error: no document data in response", seconds: 3.0)
            }
        }
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
    
    func navigateToStatusError() {
        self.performSegue(withIdentifier: "DocPhotoCheckToError", sender: nil)
        
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
            if (self.viewModel.uploadResponse?.data?.document == nil) {
                let errText = "Error: Cannot find document id for navigation!"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                vc.docId = self.viewModel.uploadResponse?.data?.document
            }
        }
        if (segue.identifier == "CheckPhotoToZoom") {
            let vc = segue.destination as! ZoomedDocPhotoViewController
            vc.photoToZoom = sender as! UIImage?
        }
        if (segue.identifier == "DocPhotoCheckToError") {
            let vc = segue.destination as! DocPhotoVerifErrorViewController
            vc.firstPhoto = self.firstPhoto
            vc.statusCode = self.viewModel.uploadResponse?.data?.status
            if (self.secondPhoto != nil) {
                vc.secondPhoto = self.secondPhoto
            }
            if (self.viewModel.uploadResponse?.data?.document == nil) {
                let errText = "Error: Cannot find document id for navigation!"
                self.showToast(message: errText, seconds: 2.0)
            } else {
                vc.docId = self.viewModel.uploadResponse?.data?.document
            }
        }
    }
    
    func moveToChooseDocTypeViewController() {
        //!
        let viewController = self.navigationController?.viewControllers.first { $0 is ChooseDocTypeViewController }
        guard let destinationVC = viewController else { return }
        self.navigationController?.popToViewController(destinationVC, animated: true)
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
        tvLoadingDescl.text = "photo_loaing_wait_discl".localized
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
