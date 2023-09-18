//
//  InitProviderViewModel.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 12.04.2023.
//

import Foundation

class InitProviderViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    init() {}
    
    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    var currentStageResponse: StageResponse?
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didReceivedCurrentStage: (() -> ())?
    
    
    func initProvider(initProviderRequestBody: InitProviderRequestBody) {
        
        self.dataService.initProvider(initProviderRequestBody: initProviderRequestBody,
                                      completion: { (success, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            if (success == true) {
                self.getCurrentStage()
            } else {
                self.isLoading = false
                self.error = VCheckApiError(errorText: "Unknown error: Failed to initialize verification",
                                            errorCode: 0)
            }
        })
    }
    
    func getCurrentStage() {
        
        self.dataService.getCurrentStage(checkStageError: true, completion: { (data, error) in
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
