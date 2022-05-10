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
    
    @IBOutlet weak var videoProcessingIndicator: UIActivityIndicatorView!
    
    //private var sampleBuffer: [CMSampleBuffer] = []
    
    var videoFileURL: URL?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = LocalDatasource.shared.readAccessToken()
        
//        print("========== TOKEN: \(token)")
//        print("========== COMPOSED VIDEO FILE PATH: \(videoFilePath ?? "EMPTY!")")
        
        if (token.isEmpty && videoFileURL != nil) {
            //print("=========== VIDEO FILE SIZE: \(String(describing: getSizeOfFile(withPath: videoFilePath!)))")
            playLivenessVideoPreview()
        }
    }
    
    func playLivenessVideoPreview() {
        let playerController = AVPlayerViewController()
        
        //let videoURL = URL.init(string: videoFilePath!) //NSURL(string: videoFilePath!)
        //let videoURL = URL.init(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        let player = AVPlayer(url: self.videoFileURL!)
        playerController.player = player
        self.addChild(playerController)

        playerController.view.frame = self.view.frame

        self.view.addSubview(playerController.view)

        player.play()
     }
    
    func getSizeOfFile(withPath path:String) -> UInt64? {
        var totalSpace : UInt64?

        var dict : [FileAttributeKey : Any]?

        do {
            dict = try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
             print(error.localizedDescription)
        }

        if dict != nil {
            let fileSystemSizeInBytes = dict![FileAttributeKey.systemSize] as! NSNumber

            totalSpace = fileSystemSizeInBytes.uint64Value
            return (totalSpace!/1024)/1024
        }
        return nil
    }

    func composeVideo() {

    }
}
