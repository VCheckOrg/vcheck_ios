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
    
    var isFromSegmentation: Bool = false
        
    @IBOutlet weak var secondPhotoCard: VCheckSDKRoundedView!
    
    @IBOutlet weak var imgViewPhotoFirst: UIImageView!
    @IBOutlet weak var imgViewPhotoSecond: UIImageView!
    
    @IBOutlet weak var remakeDocPhotosBtn: VCheckSDKRoundedView!
    @IBOutlet weak var confirmUploadPhotosBtn: UIButton!
    
    @IBOutlet weak var zoomFirstPhotoBtn: UIImageView!
    @IBOutlet weak var zoomSecondPhotoBtn: UIImageView!
    
    @IBOutlet weak var confirmBtnVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var remakeBtnVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tvLoadingDescl: UILabel!
    
    @IBOutlet weak var photosUploadingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var uplSpinnerTopConstraint: NSLayoutConstraint!
    
    var onRepeatBlock : ((Bool) -> Void)?
    
    
    override func viewDidLoad() {
        
        activityIndicatorStop()
        
        imgViewPhotoFirst.image = firstPhoto
        
        confirmUploadPhotosBtn.setTitle("confirm".localized, for: .normal)
        confirmUploadPhotosBtn.setTitle("confirm".localized, for: .disabled)
        
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
            self.handleDocUploadResponse(isError: false)
        }
        
        viewModel.updateLoadingStatus = {
            if (self.viewModel.isLoading == true) {
                self.activityIndicatorStart()
            } else {
                self.activityIndicatorStop()
            }
        }
        
        viewModel.showAlertClosure = {
            self.handleDocUploadResponse(isError: true)
        }
        
        let replacePhotosTap = UITapGestureRecognizer(target: self, action: #selector(replacePhotoClicked(_:)))
        let uploadPhotosTap = UITapGestureRecognizer(target: self, action: #selector(performDocUploadRequest(_:)))
        
        remakeDocPhotosBtn.addGestureRecognizer(replacePhotosTap)
        confirmUploadPhotosBtn.addGestureRecognizer(uploadPhotosTap)
    }
    
    func handleDocUploadResponse(isError: Bool) {
        self.activityIndicatorStop()
  
        if (self.viewModel.uploadResponse?.errorCode != nil && isError == true) {
            self.navigateToStatusError()
        } else {
            self.handleDocDataResponse()
        }
    }
    
    func handleDocDataResponse() {
        if (self.viewModel.uploadResponse?.data?.id != nil) {
            self.navigateToDocInfoScreen()
        } else {
            if (self.isFromSegmentation) {
                self.performSegue(withIdentifier: "CheckPhotoToFatalSegErr", sender: nil)
            } else {
                print("VCheckSDK - error: document id is nil while doing photo upload.")
            }
        }
    }
    
    @objc func replacePhotoClicked(_ sender: NavGestureRecognizer) {
        changePhoto()
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
            if (self.viewModel.uploadResponse?.data?.id != nil) {
                vc.docId = self.viewModel.uploadResponse?.data?.id
            }
            vc.isDocCheckForced = false
        }
        if (segue.identifier == "CheckPhotoToZoom") {
            let vc = segue.destination as! ZoomedDocPhotoViewController
            vc.photoToZoom = sender as! UIImage?
        }
        if (segue.identifier == "DocPhotoCheckToError") {
            let vc = segue.destination as! DocPhotoVerifErrorViewController
            
            vc.errorCode = codeIdxToVerificationCode(codeIdx: (self.viewModel.uploadResponse?.errorCode ?? 0))
            vc.isDocCheckForced = true
            if (self.viewModel.uploadResponse?.data?.id != nil) {
                vc.docId = self.viewModel.uploadResponse?.data?.id
            }
        }
        if (segue.identifier == "CheckPhotoToFatalSegErr") {
            let vc = segue.destination as! SegmentationTimeoutViewController
            vc.isInvalidDocError = true
            vc.onRepeatBlock = { result in }
        }
    }
    
    func changePhoto() {
        self.navigationController?.popViewController(animated: true)
        self.onRepeatBlock!(true)
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
