//
//  LocalDatasource.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation

class LocalDatasource {

    //https://swiftsenpai.com/development/persist-data-using-keychain/

    // MARK: - Singleton
    static let shared = LocalDatasource()

    private init() {}

    private var localeIsUserDefined: Bool = false
    
    private var verificationId: Int? = nil
    
    private var partnerId: Int? = nil
    private var secret: String? = nil
    private var langCode: String = "uk"

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
        
    func setVerificationId(id: Int) {
        self.verificationId = id
    }

    func getVerificationId() -> Int {
        if (verificationId == nil) {
            print("VCheck Demo - error: verification id not set!")
        }
        return verificationId ?? -1
    }
    
    func getCurrentSDKLangauge() -> String {
        return String(data: read(service: "vcheck-sdk-lang",
                                 account: "vcheck_demo")!, encoding: .utf8) ?? "n/a"
    }

    func saveCurrentSDKLangauge(langCode: String) {
        let data = Data(langCode.utf8)
        save(data, service: "vcheck-sdk-lang", account: "vcheck_demo")
    }

    func setLocaleIsUserDefined() {
        localeIsUserDefined = true
    }

    func isLocaleUserDefined() -> Bool {
        return localeIsUserDefined
    }
    
    func setPartnerId(id: Int) {
        self.partnerId = id
    }

    func getPartnerId() -> Int? {
        return self.partnerId
    }

    func setSecret(secret: String) {
        self.secret = secret
    }

    func getSecret() -> String? {
        return self.secret
    }
    
    func setLang(code: String) {
        self.langCode = code
    }

    func getLang() -> String {
        return self.langCode
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
