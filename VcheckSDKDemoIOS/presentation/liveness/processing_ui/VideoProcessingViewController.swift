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
            if (self.viewModel.uploadedVideoResponse == true) {
                
                self.videoProcessingTitle.isHidden = false
                self.videoProcessingDesc.isHidden = false
                self.videoProcessingSuccessButton.isHidden = false
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.livenessSuccessAction))
                tapGesture.numberOfTapsRequired = 1
                
                self.videoProcessingSuccessButton.addGestureRecognizer(tapGesture)
                
            }
        }
        
        viewModel.showAlertClosure = {
            self.activityIndicatorStop()
            
//            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
//            self.showToast(message: errText, seconds: 2.0)
            
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
        self.videoProcessingIndicator.startAnimating()
    }
    
    private func activityIndicatorStop() {
        self.videoProcessingIndicator.stopAnimating()
    }
}
