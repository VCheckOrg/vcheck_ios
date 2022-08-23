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
    
    private init() {}
    
    //cached selected doc type with data
    private var selectedDocTypeWithData: DocTypeData? = nil
    
    private var livenessMilestonesList: [String]? = nil
    
    private var localeIsUserDefined: Bool = false
    
    private var manualPhotoUpload: Bool = false
}


// MARK: - Actual Local Datasource

extension VCheckSDKLocalDatasource {
    
    func setSelectedDocTypeWithData(data: DocTypeData) {
        selectedDocTypeWithData = data
    }

    func getSelectedDocTypeWithData() -> DocTypeData? {
        return selectedDocTypeWithData
    }
    
    func setLivenessMilestonesList(list: [String]) {
        livenessMilestonesList = list
    }
    
    func getLivenessMilestonesList() -> [String]? {
        return livenessMilestonesList
    }
    
    func setManualPhotoUpload() {
        manualPhotoUpload = true
    }
    
    func isPhotoUploadManual() -> Bool {
        return manualPhotoUpload
    }
    
    func resetSessionData() {
        selectedDocTypeWithData = nil
        livenessMilestonesList = nil
        manualPhotoUpload = false
    }
}
