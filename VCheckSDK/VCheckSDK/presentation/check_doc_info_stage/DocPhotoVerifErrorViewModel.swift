//
//  DocPhotoVerifErrorViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 12.05.2022.
//

import Foundation

class DocPhotoVerifErrorViewModel {
    
    private var dataService: RemoteDatasource = RemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    // MARK: - Properties
    var docInfoResponse: PreProcessedDocData? = nil
    var confirmedDocResponse: Bool = false
   
    var error: VCheckApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didReceiveConfirmResponse: (() -> ())?
    
    
    func setDocAsPrimary(docId: Int) {
        
        //TODO: test!
        dataService.updateAndConfirmDocInfo(documentId: docId, parsedDocFieldsData:
                                                DocUserDataRequestBody(data: ParsedDocFieldsData(), isForced: false),
                                            completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
            self.isLoading = false
            
            self.confirmedDocResponse = true
            self.didReceiveConfirmResponse!()
        })
    }
    
}
