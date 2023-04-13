//
//  ChooseDocTypeViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 30.04.2022.
//

import Foundation

class ChooseDocTypeViewModel  {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    // MARK: - Properties
    var docTypeDataArr: [DocTypeData] = []
    
    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var retrievedDocTypes: (() -> ())?
    
    
    func getAvailableDocTypes() {
        
        let countryCode = VCheckSDK.shared.getOptSelectedCountryCode()!
        //assuming that provider should have country in the scenario of country choosing
        
        self.dataService.getAvailableDocTypes(countryCode: countryCode, completion: { (data, error) in
            if let error = error {
                self.error = error
                return
            }
                        
            if (data!.count > 0) {
                self.docTypeDataArr = data!
                self.retrievedDocTypes!()
            }
        })
    }
    
}
