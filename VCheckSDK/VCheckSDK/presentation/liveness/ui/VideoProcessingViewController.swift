//
//  VideoUploadViewController.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation
import UIKit
import CoreMedia
import AVKit
import Photos

class VideoProcessingViewController: UIViewController {
    
    private let viewModel = VideoProcessingViewModel()
    
    var livenessVC: LivenessScreenViewController? = nil
    
    @IBOutlet weak var videoProcessingIndicator: UIActivityIndicatorView!
        
    var videoFileURL: URL?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoProcessingIndicator.isHidden = false
        
        let token = VCheckSDK.shared.getVerificationToken()
        
        self.viewModel.didUploadVideoResponse = {
            if (self.viewModel.uploadedVideoResponse != nil) {
                if (self.viewModel.uploadedVideoResponse!.isFinal == true) {
                    self.livenessSuccessAction()
                } else {
                    if (statusCodeToLivenessChallengeStatus(code: self.viewModel.uploadedVideoResponse!.status!)
                        == LivenessChallengeStatus.FAIL) {
                        if (self.viewModel.uploadedVideoResponse!.reason != nil
                            && !self.viewModel.uploadedVideoResponse!.reason!.isEmpty) {
                                self.onBackendObstacleMet(reason: strCodeToLivenessFailureReason(
                                    strCode: (self.viewModel.uploadedVideoResponse?.reason!)!))
                        } else {
                            self.livenessSuccessAction()
                        }
                    } else {
                        self.livenessSuccessAction()
                    }
                }
            }
        }
        
        self.viewModel.didReceivedCurrentStage = {
            if (self.viewModel.currentStageResponse?.errorCode == nil ||
                    (self.viewModel.currentStageResponse?.errorCode != nil &&
                     self.viewModel.currentStageResponse!.errorCode! >
                        StageErrorType.VERIFICATION_NOT_INITIALIZED.toTypeIdx())) {
                VCheckSDK.shared.finish(executePartnerCallback: true)
            } else {
                self.showToast(message: "Unexpected Stage Error", seconds: 2.0)
            }
        }
        
        self.viewModel.showAlertClosure = {
            self.performSegue(withIdentifier: "VideoUploadToFailure", sender: nil)
        }
        
        if (!token.isEmpty && videoFileURL != nil) {
            uploadVideo()
        } else {
            print("VCheckSDK - Error: token or video file is nil")
        }
    }
    
    func onBackendObstacleMet(reason: LivenessFailureReason) {
        switch(reason) {
            case LivenessFailureReason.FACE_NOT_FOUND:
                self.performSegue(withIdentifier: "InProcessToLookStraight", sender: nil)
            case LivenessFailureReason.MULTIPLE_FACES:
                self.performSegue(withIdentifier: "InProcessToObstacles", sender: nil)
            case LivenessFailureReason.FAST_MOVEMENT:
                self.performSegue(withIdentifier: "InProcessToSharpMovement", sender: nil)
            case LivenessFailureReason.TOO_DARK:
                self.performSegue(withIdentifier: "InProcessToTooDark", sender: nil)
            case LivenessFailureReason.INVALID_MOVEMENTS:
                self.performSegue(withIdentifier: "InProcessToWrongGesture", sender: nil)
            case LivenessFailureReason.UNKNOWN:
                self.performSegue(withIdentifier: "InProcessToObstacles", sender: nil)
        }
    }
    
    //TODO: TEST!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "InProcessToLookStraight") {
            let vc = segue.destination as! NoFaceDetectedViewController
            vc.onRepeatBlock = { result in
                self.navigationController?.popViewController(animated: false)
                self.livenessVC?.renewLivenessSessionOnRetry()
            }
        }
        if (segue.identifier == "InProcessToObstacles") {
            let vc = segue.destination as! MultipleFacesDetectedViewController
            vc.onRepeatBlock = { result in
                self.navigationController?.popViewController(animated: false)
                self.livenessVC?.renewLivenessSessionOnRetry()
            }
        }
        if (segue.identifier == "InProcessToSharpMovement") {
            let vc = segue.destination as! SharpMovementsViewController
            vc.onRepeatBlock = { result in
                self.navigationController?.popViewController(animated: false)
                self.livenessVC?.renewLivenessSessionOnRetry()
            }
        }
        if (segue.identifier == "InProcessToTooDark") {
            let vc = segue.destination as! NoBrightnessViewController
            vc.onRepeatBlock = { result in
                self.navigationController?.popViewController(animated: false)
                self.livenessVC?.renewLivenessSessionOnRetry()
            }
        }
        if (segue.identifier == "InProcessToWrongGesture") {
            let vc = segue.destination as! WrongGestureViewController
            vc.onRepeatBlock = { result in
                self.navigationController?.popViewController(animated: false)
                self.livenessVC?.renewLivenessSessionOnRetry()
            }
        }
        if (segue.identifier == "VideoUploadToFailure") {
            let vc = segue.destination as! VideoFailureViewController
            vc.videoProcessingViewController = self
        }
    }
    
    func livenessSuccessAction() {
        self.viewModel.getCurrentStage()
    }
    
    func uploadVideo() {
        viewModel.uploadVideo(videoFileURL: videoFileURL!)
    }
}
