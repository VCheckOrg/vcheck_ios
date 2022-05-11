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
        
    var videoFileURL: URL?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorStart()
        
        let token = LocalDatasource.shared.readAccessToken()
        
        viewModel.didUploadVideoResponse = {
            self.activityIndicatorStop()
            if (self.viewModel.uploadedVideoResponse == true) {
                self.performSegue(withIdentifier: "VideoUploadToSuccess", sender: nil)
            }
        }
        
        viewModel.showAlertClosure = {
            self.activityIndicatorStop()
            let errText = self.viewModel.error?.errorText ?? "Error: No additional info"
            self.showToast(message: errText, seconds: 2.0)
        }
        
        if (!token.isEmpty && videoFileURL != nil) {
            viewModel.uploadVideo(videoFileURL: videoFileURL!)
        } else {
            //FOR TESTS
            if (videoFileURL != nil) {
                print("=========== VIDEO FILE SIZE: \(String(describing: self.viewModel.fileSize(forURL: videoFileURL))) MB")
                playLivenessVideoPreview()
            }
        }
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
