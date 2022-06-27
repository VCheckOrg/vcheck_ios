//
//  KeychainHelper.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation

class LocalDatasource {
    
    //https://swiftsenpai.com/development/persist-data-using-keychain/
    
    // MARK: - Singleton
    static let shared = LocalDatasource()
    
    private init() {}
    
    
    //cached selected doc type with data
    private var selectedDocTypeWithData: DocTypeData? = nil
    
    private var localeIsUserDefined: Bool = false
    
    
    
    func save(_ data: Data, service: String, account: String) {

        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        // Add data in query to keychain
        let status = SecItemAdd(query, nil)

        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            // Update existing item
            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    func read(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}


    // MARK: - Actual Local Datasource

extension LocalDatasource {
    
    func readAccessToken() -> String {
        return String(data: read(service: "access-token",
                                 account: Constants.UTIL.keychainAccountName)!, encoding: .utf8) ?? ""
    }
    
    func saveAccessToken(accessToken: String) {
        let data = Data(accessToken.utf8)
        save(data, service: "access-token", account: Constants.UTIL.keychainAccountName)
    }
    
    func readSelectedCountryCode() -> String {
        return String(data: read(service: "country-code",
                                 account: Constants.UTIL.keychainAccountName)!, encoding: .utf8) ?? ""
    }
    
    func saveSelectedCountryCode(code: String) {
        let data = Data(code.utf8)
        save(data, service: "country-code", account: Constants.UTIL.keychainAccountName)
    }
    
    func setSelectedDocTypeWithData(data: DocTypeData) {
        selectedDocTypeWithData = data
    }

    func getSelectedDocTypeWithData() -> DocTypeData? {
        return selectedDocTypeWithData
    }
    
    func resetAccessToken() {
        let data = Data("".utf8)
        save(data, service: "access-token", account: Constants.UTIL.keychainAccountName)
    }
    
    func resetSelectedCountryCode() {
        let data = Data("".utf8)
        save(data, service: "country-code", account: Constants.UTIL.keychainAccountName)
    }
    
    func deleteSelectedDocTypeWithData() {
        selectedDocTypeWithData = nil
    }
    
    func getCurrentSDKLangauge() -> String {
        return String(data: read(service: "vcheck-sdk-lang",
                                 account: Constants.UTIL.keychainAccountName)!, encoding: .utf8) ?? "en"
    }

    func saveCurrentSDKLangauge(langCode: String) {
        let data = Data(langCode.utf8)
        save(data, service: "vcheck-sdk-lang", account: Constants.UTIL.keychainAccountName)
    }

    func setLocaleIsUserDefined() {
        localeIsUserDefined = true
    }
    
    func isLocaleUserDefined() -> Bool {
        return localeIsUserDefined
    }
    
    func deleteAllSessionData() {
        localeIsUserDefined = false
        resetAccessToken()
        resetSelectedCountryCode()
        deleteSelectedDocTypeWithData()
    }
}



    // MARK: - Utils

extension LocalDatasource {
    
    func save<T>(_ item: T, service: String, account: String) where T : Codable {
        
        do {
            // Encode as JSON data and save in keychain
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account)
            
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }
    
    func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        
        // Read item data from keychain
        guard let data = read(service: service, account: account) else {
            return nil
        }
        
        // Decode JSON data to object
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }
    
}
