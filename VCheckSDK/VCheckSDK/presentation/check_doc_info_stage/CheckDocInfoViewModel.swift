//
//  CheckDocInfoViewModel.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 05.05.2022.
//

import Foundation

class CheckDocInfoViewModel {
    
    private var dataService: VCheckSDKRemoteDatasource = VCheckSDKRemoteDatasource.shared
    
    // MARK: - Constructor
    init() {}
    
    
    // MARK: - Properties
    var docInfoResponse: PreProcessedDocData? = nil
    var confirmedDocResponse: Bool = false
   
    var currentStageResponse: StageResponse?

    var error: VCheckApiError? {
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
    
    var didReceivedCurrentStage: (() -> ())?
    
    
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
    
    func updateAndConfirmDocument(docId: Int, parsedDocFieldsData: DocUserDataRequestBody) {
        
        dataService.updateAndConfirmDocInfo(documentId: docId,
                                            parsedDocFieldsData: parsedDocFieldsData,
                                            completion: { (data, error) in
            if let error = error {
                self.isLoading = false
                if (error.errorCode != nil) {
                    if (error.errorCode != BaseClientErrors.PRIMARY_DOCUMENT_EXISTS_OR_USER_INTERACTION_COMPLETED) {
                        self.error = error
                        return
                    } else {
                        self.getCurrentStage()
                        return
                    }
                } else {
                    self.error = error
                    return
                }
            }
            self.isLoading = false
            
            self.confirmedDocResponse = data
            self.didReceiveConfirmedResponse!()
        })
    }
    
    func getCurrentStage() {
        
        self.dataService.getCurrentStage(checkStageError: true, completion: { (data, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.isLoading = false
            
            if (data!.data != nil || data!.errorCode != nil) {
                self.currentStageResponse = data
                self.didReceivedCurrentStage!()
            }
        })
    }
}
