//
//  CheckDocPhotoViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 04.05.2022.
//

import Foundation
import UIKit

class CheckDocPhotoViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    var uploadResponse: DocumentUploadResponse? = nil

    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didReceiveDocUploadResponse: (() -> ())?
    
    
    func sendDocForVerifUpload(photo1: UIImage, photo2: UIImage?) {
        
        self.isLoading = true
        
        let countryCode: String = VCheckSDK.shared.getSelectedCountryCode()
        
        let docType: Int = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()!.category!
        
        let docTypeStr: String = "\(docType)"
            
        dataService.uploadVerificationDocuments(photo1: photo1,
                                                photo2: photo2,
                                                countryCode: countryCode,
                                                category: docTypeStr,
                                                completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
                        
            self.isLoading = false
            self.uploadResponse = data
            self.didReceiveDocUploadResponse!()
        })
    }
}
