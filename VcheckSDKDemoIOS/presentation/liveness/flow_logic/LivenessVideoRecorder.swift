//
//  MovieRecorder.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation
import AVFoundation
import UIKit

class LivenessVideoRecorder {
    
    var outputFileURL: URL?
    
    private var assetWriter: AVAssetWriter?
    
    private var assetWriterVideoInput: AVAssetWriterInput?
        
    private var videoTransform: CGAffineTransform?
    
    private var videoSettings: [String: Any]?

    private(set) var isRecording = false
    
    func getVideoTransform() -> CGAffineTransform {
            switch UIDevice.current.orientation {
                case .portrait:
                    return CGAffineTransform(rotationAngle: 90.degreesToRadians)
                case .portraitUpsideDown:
                    return CGAffineTransform(rotationAngle: 180)
                case .landscapeLeft:
                    return CGAffineTransform(rotationAngle: 0.degreesToRadians)
                case .landscapeRight:
                    return CGAffineTransform(rotationAngle: 180.degreesToRadians)
                default:
                    return CGAffineTransform(rotationAngle: 90.degreesToRadians)
            }
        }
    
    func startRecording() {
        
        //Seeting codec resolution to 960x540 as we're using .iFrame960x540 as AVCaptureSession preset
        videoSettings = [AVVideoCodecKey : AVVideoCodecType.h264,
                              AVVideoWidthKey : NSNumber(value: Float(960)),
                              AVVideoHeightKey : NSNumber(value: Float(540))]
                          as [String : Any]
        
        self.videoTransform = getVideoTransform()
        
        // Create an asset writer that records to a temporary file
        let outputFileName = NSUUID().uuidString
        
        outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(outputFileName).appendingPathExtension("MP4") //MOV
        
        print("======= OUTPUT FILE URL: \(String(describing: outputFileURL))")
        
        guard let assetWriter = try? AVAssetWriter(url: outputFileURL!, fileType: .mp4) else {
            return
        }
        
        // Add a video input
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = videoTransform!
        assetWriter.add(assetWriterVideoInput)
        
        self.assetWriter = assetWriter
        //self.assetWriterAudioInput = assetWriterAudioInput
        self.assetWriterVideoInput = assetWriterVideoInput
        
        isRecording = true
    }
    
    func stopRecording(completion: @escaping (URL) -> Void) {
        guard let assetWriter = assetWriter else {
            return
        }
        
        self.isRecording = false
        self.assetWriter = nil
        
        assetWriter.finishWriting {
            completion(assetWriter.outputURL)
        }
    }
    
    func recordVideo(sampleBuffer: CMSampleBuffer) {
        guard isRecording,
            let assetWriter = assetWriter else {
                return
        }
        
        if assetWriter.status == .unknown {
            print("STATUS UNKNOWN")
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        } else if assetWriter.status == .writing {
            if let input = assetWriterVideoInput,
                input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
    }

}