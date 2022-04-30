//
//  ChooseDocTypeViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 30.04.2022.
//

import Foundation

class ChooseDocTypeViewModel  {
    
    private var dataService: DataService = DataService.shared
    
    // MARK: - Constructor
    init() {}
    
    var docTypeDataArr: [DocTypeData] = []
    
    var error: ApiError? {
        didSet { self.showAlertClosure?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var retrievedDocTypes: (() -> ())?
    
    
    func getAvailableDocTypes() {
        
        let countryCode = KeychainHelper.shared.readSelectedCountryCode()
        
        self.dataService.getCountryAvailableDocTypeInfo(countryCode: countryCode, completion: { (data, error) in
            if let error = error {
                self.error = error
                //self.isLoading = false
                return
            }
            
            //print("VERIF ::: GOT COUNTRIES - SUCCESS! DATA: \(String(describing: data))")
            
            if (data!.count > 0) {
                //self.isLoading = false
                //self.countries = data
                
                self.docTypeDataArr = data!
                
                self.retrievedDocTypes!()
            }
        })
    }
    
}
