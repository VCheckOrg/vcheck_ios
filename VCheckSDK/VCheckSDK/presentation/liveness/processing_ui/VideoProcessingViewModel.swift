//
//  VideoUploadViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 10.05.2022.
//

import Foundation

class VideoProcessingViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    var uploadedVideoResponse: LivenessUploadResponseData? = nil
   
    var currentStageResponse: StageResponse?

    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didUploadVideoResponse: (() -> ())?
    
    var didReceivedCurrentStage: (() -> ())?
    
    
    func uploadVideo(videoFileURL: URL) {
        
        dataService.uploadLivenessVideo(videoFileURL: videoFileURL,
                                        completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
            self.isLoading = false
            if let data = data {
                self.uploadedVideoResponse = data
                self.didUploadVideoResponse!()
            }
        })
    }
    
    func getCurrentStage() {
        
        self.dataService.getCurrentStage(checkStageError: false, completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            if (data!.data != nil || data!.errorCode != nil) {
                self.currentStageResponse = data
                self.didReceivedCurrentStage!()
            }
        })
    }
}
