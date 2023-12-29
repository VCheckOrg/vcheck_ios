//
//  RemoteDatasource.swift
//  Demo
//
//  Created by Kirill Kaun on 28.12.2023.
//

import Foundation
import Alamofire
import VCheckSDK

//TODO: rename to VCheckLocalDatasource!
struct RemoteDatasource {
    
    // MARK: - Singleton
    static let shared = RemoteDatasource()
    
    // MARK: - URL
    static let partnerBaseUrl = URL(string: "https://test-partner.vycheck.com/v1/")!
    static let verifBaseUrl = URL(string: "https://test-verification.vycheck.com/api/v1/")!
    
    // MARK: - API calls
    
    
    
    func requestServerTimestamp(completion: @escaping (String?, String?) -> ()) {
        let url = "\(RemoteDatasource.verifBaseUrl)timestamp"
        
        AF.request(url, method: .get)
          .responseString(completionHandler: { (response) in
            guard let timestamp = response.value else {
                completion(nil, "requestServerTimestamp: "
                           + response.error!.localizedDescription
                           + "\(String(describing: response.response?.statusCode))")
                return
            }
              completion(timestamp, nil)
              return
          })
    }
    
    func createVerificationRequest(model: PartnerApplicationRequestData,
                                   completion: @escaping (Bool?, String?) -> ()) {
        let url = "\(RemoteDatasource.partnerBaseUrl)form/partner_request"

        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try model.toDictionary()
        } catch {
            completion(false, "Error: Failed to convert model!")
            return
        }

        AF.request(url, method: .post, parameters: jsonData, encoding: JSONEncoding.default)
            .response(completionHandler: { (response) in
                guard response.value != nil else {
                 completion(false, "Server error")
                 return
                }
                completion(true, nil)
                return
            })
    }
    
    func createVerificationRequest(timestamp: String,
                                   locale: String,
                                   scheme: String,
                                   completion: @escaping (VerificationCreateAttemptResponseData?, String?) -> ()) {
        let url = "\(RemoteDatasource.partnerBaseUrl)verifications"

        let model = CreateVerificationRequestBody.init(ts: timestamp, locale: locale, scheme: scheme)

        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try model.toDictionary()
        } catch {
            completion(nil, "Error: Failed to convert model!")
            return
        }

        AF.request(url, method: .post, parameters: jsonData, encoding: JSONEncoding.default)
          .responseDecodable(of: VerificationCreateAttemptResponse.self) { (response) in
            guard let response = response.value else {
                completion(nil, "createVerificationRequest: "
                           + response.error!.localizedDescription
                           + "\(String(describing: response.response?.statusCode))")
                return
            }
              
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, "\(String(describing: response.errorCode)): "
                                       + "\(response.message ?? "")")
                  return
              }
              completion(response.data, nil)
              return
          }
    }
    
    func checkFinalVerificationStatus(completion: @escaping (FinalVerifCheckResponseModel?, String?) -> ()) {

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, "Error: cannot find access token")
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        requestServerTimestamp(completion: { (timestamp, error) in
            if error != nil {
                completion(nil, "Error: Service timestamp was not retrieved")
                return
            } else {
                
                let sign = "\(String(describing: LocalDatasource.shared.getPartnerId()))\(timestamp!)\(LocalDatasource.shared.getVerificationId())\(String(describing: LocalDatasource.shared.getSecret()))".sha256()
                
                let url = "\(RemoteDatasource.partnerBaseUrl)verifications/\(LocalDatasource.shared.getVerificationId())?partner_id=\(String(describing: LocalDatasource.shared.getPartnerId()))&timestamp=\(timestamp!)&sign=\(sign)"
                
                AF.request(url, method: .get, headers: headers)
                  .responseDecodable(of: FinalVerifCheckResponseModel.self) { (response) in
                    guard let response = response.value else {
                        completion(nil, "getCountryAvailableDocTypeInfo: "
                                   + response.error!.localizedDescription
                                   + "\(String(describing: response.response?.statusCode))")
                        return
                    }
                      if (response.errorCode != nil && response.errorCode != 0) {
                          completion(nil, "\(String(describing: response.errorCode)): "
                                                   + "\(response.message ?? "")")
                          return
                      }
                          completion(response, nil)
                          return
                  }
            }
            
        })
    }

}


extension Encodable {

    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
}

