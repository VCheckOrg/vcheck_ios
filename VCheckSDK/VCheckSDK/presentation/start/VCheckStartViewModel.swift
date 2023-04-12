//
//  DemoStartViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

class VCheckStartViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    init() {}
    
    // MARK: - Properties
    private var timestamp: String?
    
    var currentStageResponse: StageResponse?
    
    var providers: [Provider]?

    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    //var didCreateVerif: (() -> ())?
    
    var verificationIsAlreadyCompleted: (() -> ())?
    
    var gotProviders: (() -> ())?
    
    
    // MARK: - Data calls
    
    func startVerifFlow() {
        self.isLoading = true
        
        self.dataService.requestServerTimestamp(completion: { (timestamp, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.timestamp = timestamp
            self.initVerif()
        })
    }
    
    func initVerif() {
        
        self.dataService.initVerification(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            if let status = data?.status {
                if (status > VerificationStatuses.WAITING_USER_INTERACTION) {
                    self.isLoading = false
                    self.verificationIsAlreadyCompleted!()
                } else {
                    self.getProviders()
                }
            } else {
                self.isLoading = false
                self.error = VCheckApiError(errorText: "Unknown error: Failed to initialize verification",
                                            errorCode: 0)
            }
        })
    }
    
    func getProviders() {
        
        self.dataService.getProviders(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            if let d = data?.data {
                self.providers = d
                self.gotProviders!()
            } else {
                self.isLoading = false
                self.error = VCheckApiError(errorText: "Unknown error: Failed to get providers",
                                            errorCode: 0)
            }
        })
    }
}
