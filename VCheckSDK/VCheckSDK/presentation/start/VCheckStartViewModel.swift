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
    
    var countries: [Country]?

    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didCreateVerif: (() -> ())?
    
    var didInitVerif: (() -> ())?
    
    var didFinishFetch: (() -> ())?
    var gotCountries: (() -> ())?
    
    var didReceivedCurrentStage: (() -> ())?
    
    
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
            self.getCurrentStage()
        })
    }
    
    func getCurrentStage() {
        
        self.dataService.getCurrentStage(completion: { (data, error) in
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
    
    func getCountries() {
        
        self.dataService.getCountries(completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
                                    
            if (data!.count > 0) {
                self.isLoading = false
                self.countries = data
                self.gotCountries!()
            }
        })
    }
    
}
