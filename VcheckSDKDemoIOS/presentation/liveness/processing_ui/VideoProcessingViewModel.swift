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
    var uploadedVideoResponse: Bool = false
   

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
    
    
    func uploadVideo() {
        
//        dataService.getDocumentInfo(documentId: docId, completion: { (data, error) in
//            if let error = error {
//                self.isLoading = false
//                self.error = error
//                return
//            }
//            self.isLoading = false
//
//            self.docInfoResponse = data
//            self.didReceiveDocInfoResponse!()
//        })
    }
}
