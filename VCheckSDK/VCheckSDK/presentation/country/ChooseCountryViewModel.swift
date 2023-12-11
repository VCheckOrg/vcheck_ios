//
//  ChooseCountryViewModel.swift
//  VCheckSDK
//
//  Created by Kirill Kaun on 07.07.2023.
//

import Foundation

class ChooseCountryViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    // MARK: - Properties
    var priorityCountriesResponse: PriorityCountries? = nil

    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didReceivePriorityCountriesResponse: (() -> ())?
    
    
    func getPriorityCountries() {
        
        self.isLoading = true
        
        dataService.getPriorityCountries(completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
                        
            self.isLoading = false
            self.priorityCountriesResponse = data
            self.didReceivePriorityCountriesResponse!()
        })
    }
}
