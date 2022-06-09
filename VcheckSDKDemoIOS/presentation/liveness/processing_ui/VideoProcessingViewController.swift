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

class VideoProcessingViewController: UIViewController {
    
    private let viewModel = VideoProcessingViewModel()
    
    var livenessVC: LivenessScreenViewController? = nil
    
    @IBOutlet weak var videoProcessingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var videoProcessingTitle: UILabel!
    @IBOutlet weak var videoProcessingDesc: UILabel!
    
    @IBOutlet weak var videoProcessingSuccessButton: UIButton!
    
    var videoFileURL: URL?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoProcessingTitle.isHidden = true
        self.videoProcessingDesc.isHidden = true
        self.videoProcessingSuccessButton.isHidden = true
        
        activityIndicatorStart()
        
        let token = LocalDatasource.shared.readAccessToken()
        
        viewModel.didUploadVideoResponse = {
            self.activityIndicatorStop()
            if (self.viewModel.uploadedVideoResponse != nil) {
                print("DATA: ${uploadResponse.data}")
                if (self.viewModel.uploadedVideoResponse?.isFinal == true) {
                    self.showToast(message: "[TEST] This upload response is final!", seconds: 2)
                    self.onVideoUploadResponseSuccess()
                }
                if (statusCodeToLivenessChallengeStatus(code: self.viewModel.uploadedVideoResponse!.status!)
                        == LivenessChallengeStatus.FAIL) {
                    if (self.viewModel.uploadedVideoResponse!.reason != nil
                        && !self.viewModel.uploadedVideoResponse!.reason!.isEmpty) {
                        self.onBackendObstacleMet(reason: strCodeToLivenessFailureReason(
                            strCode: (self.viewModel.uploadedVideoResponse?.reason!)!))
                    } else {
                        self.onVideoUploadResponseSuccess()
                    }
                } else {
                    self.onVideoUploadResponseSuccess()
                }
            }
        }
        
        viewModel.showAlertClosure = {
            self.activityIndicatorStop()
            self.performSegue(withIdentifier: "VideoUploadToFailure", sender: nil)
        }
        
        if (!token.isEmpty && videoFileURL != nil) {
            uploadVideo()
        } else {
            //FOR TESTS
            if (videoFileURL != nil) {
                print("=========== VIDEO FILE SIZE: \(String(describing: self.viewModel.fileSize(forURL: videoFileURL))) MB")
                playLivenessVideoPreview()
            }
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
    }
    
    func onVideoUploadResponseSuccess() {
        self.videoProcessingTitle.isHidden = false
        self.videoProcessingDesc.isHidden = false
        self.videoProcessingSuccessButton.isHidden = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.livenessSuccessAction))
        tapGesture.numberOfTapsRequired = 1
        
        self.videoProcessingSuccessButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func livenessSuccessAction() {
        //Close app for new test
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
    }
    
    func uploadVideo() {
        viewModel.uploadVideo(videoFileURL: videoFileURL!)
    }
    
    func playLivenessVideoPreview() {
        //let videoURL = URL.init(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")

        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: self.videoFileURL!)
        playerController.player = player
        
        self.addChild(playerController)
        playerController.view.frame = self.view.frame
        self.view.addSubview(playerController.view)

        player.play()
     }
    
    // MARK: - UI Setup
    private func activityIndicatorStart() {
        self.videoProcessingIndicator.isHidden = false
        self.videoProcessingIndicator.startAnimating()
    }
    
    private func activityIndicatorStop() {
        self.videoProcessingIndicator.isHidden = true
        self.videoProcessingIndicator.stopAnimating()
    }
}
