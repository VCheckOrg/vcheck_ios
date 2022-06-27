//
//  VideoUploadViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation

class VideoProcessingViewModel {
    
    private var dataService: RemoteDatasource = RemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    var uploadedVideoResponse: LivenessUploadResponseData? = nil
   

    var error: ApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didUploadVideoResponse: (() -> ())?
    
    
    func uploadVideo(videoFileURL: URL) {
        
        dataService.uploadLivenessVideo(videoFileURL: videoFileURL,
                                        completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
            self.isLoading = false
            
            self.uploadedVideoResponse = data!
            print("LIVENESS UPLOAD - response: \(String(describing: self.uploadedVideoResponse))")
            
            self.didUploadVideoResponse!()
        })
    }
    
    func fileSize(forURL: URL?) -> Double {
        guard let filePath = forURL?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
}
