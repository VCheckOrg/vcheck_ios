//
//  CheckDocInfoViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 05.05.2022.
//

import Foundation

class CheckDocInfoViewModel {
    
    private var dataService: RemoteDatasource = RemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    var docInfoResponse: PreProcessedDocData? = nil
    var confirmedDocResponse: Bool = false
   

    var error: ApiError? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    
    var didReceiveDocInfoResponse: (() -> ())?
    var didReceiveConfirmedResponse: (() -> ())?
    
    
    func getDocumentInfo(docId: Int) {
        
        dataService.getDocumentInfo(documentId: docId, completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                self.error = error
                return
            }
            self.isLoading = false
            
            self.docInfoResponse = data
            self.didReceiveDocInfoResponse!()
        })
    }
    
    func updateAndConfirmDocument(docId: Int) {
        
        //dataService.updateAndConfirmDocInfo(documentId: docId, parsedDocFieldsData: <#T##ParsedData#>, completion: <#T##(Bool, ApiError?) -> ()#>)
    }
}
