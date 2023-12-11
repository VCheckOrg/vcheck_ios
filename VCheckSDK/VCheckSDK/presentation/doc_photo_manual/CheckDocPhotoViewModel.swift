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
        
        if let docType = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()?.category,
           let countryCode = VCheckSDKLocalDatasource.shared.getSelectedDocTypeWithData()?.country {
            let docTypeStr: String = "\(docType)"
            
            let isManual: Bool = VCheckSDKLocalDatasource.shared.isPhotoUploadManual()
                
            dataService.uploadVerificationDocuments(photo1: photo1,
                                                    photo2: photo2,
                                                    countryCode: countryCode,
                                                    category: docTypeStr,
                                                    manual: isManual,
                                                    completion: { (data, error) in
                if let error = error {
                    self.isLoading = false
                    if (data != nil) {
                        self.uploadResponse = data
                    }
                    self.error = error
                    return
                }
                            
                self.isLoading = false
                self.uploadResponse = data
                self.didReceiveDocUploadResponse!()
            })
        } else {
            self.error = VCheckApiError(errorText:
                "Error: no Selected Doc Type With Data provided for seg start view controller",
                errorCode: nil)
            return
        }
    }
}
