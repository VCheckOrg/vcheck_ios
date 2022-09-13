//
//  KeychainHelper.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

class VCheckSDKLocalDatasource {
        
    // MARK: - Singleton
    static let shared = VCheckSDKLocalDatasource()
    
    //cached selected doc type with data
    private var selectedDocTypeWithData: DocTypeData? = nil
    
    private var livenessMilestonesList: [String]? = nil
    
    private var localeIsUserDefined: Bool = false
    
    private var manualPhotoUpload: Bool = false
}


// MARK: - Actual Local Datasource

extension VCheckSDKLocalDatasource {
    
    func setSelectedDocTypeWithData(data: DocTypeData) {
        self.selectedDocTypeWithData = data
    }

    func getSelectedDocTypeWithData() -> DocTypeData {
        print("--- DOC TYPE DATA: \(String(describing: self.selectedDocTypeWithData))")
        return self.selectedDocTypeWithData!
    }
    
    func setLivenessMilestonesList(list: [String]) {
        self.livenessMilestonesList = list
    }
    
    func getLivenessMilestonesList() -> [String]? {
        return self.livenessMilestonesList
    }
    
    func setManualPhotoUpload() {
        self.manualPhotoUpload = true
    }
    
    func isPhotoUploadManual() -> Bool {
        return self.manualPhotoUpload
    }
    
    func resetSessionData() {
        self.selectedDocTypeWithData = nil
        self.livenessMilestonesList = nil
        self.manualPhotoUpload = false
    }
}
