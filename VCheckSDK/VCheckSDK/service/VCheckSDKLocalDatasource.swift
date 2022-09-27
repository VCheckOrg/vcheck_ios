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
    
    static let cache = NSCache<NSString, StructWrapper<Any>>()
    
    private var livenessMilestonesList: [String]? = nil

    private var localeIsUserDefined: Bool = false

    private var manualPhotoUpload: Bool = false
    
    func setSelectedDocTypeWithData(data: DocTypeData) {
        VCheckSDKLocalDatasource.cache.setObject(StructWrapper.init(data), forKey: "DocTypeData")
    }

    func getSelectedDocTypeWithData() -> DocTypeData? {
        return VCheckSDKLocalDatasource.cache.object(forKey: "DocTypeData")?.value as! DocTypeData?
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
    
    func resetCache() {
        self.livenessMilestonesList = nil
        self.manualPhotoUpload = false
    }
}


class StructWrapper<T>: NSObject, NSDiscardableContent {
    
    let value: T

    init(_ _struct: T) {
        self.value = _struct
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
    }
    
    func discardContentIfPossible() {
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}
