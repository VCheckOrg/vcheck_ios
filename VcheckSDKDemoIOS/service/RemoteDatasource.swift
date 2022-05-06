//
//  DataService.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
import Alamofire

struct RemoteDatasource {
    
    // MARK: - Singleton
    static let shared = RemoteDatasource()
    
    // MARK: - URL
    private let baseUrl = Constants.API.serviceBaseURL
    
    
    // MARK: - Services
    
    func requestServerTimestamp(completion: @escaping (String?, ApiError?) -> ()) {
        let url = "\(baseUrl)timestamp"
        
        AF.request(url, method: .get)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseString(completionHandler: { (response) in
            guard let timestamp = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription))
                return
            }
              completion(timestamp, nil)
              return
          })
    }
    
    // with pre-composed test request body
    func createVerificationRequest(timestamp: String,
                                   locale: String,
                                   completion: @escaping (VerificationCreateAttemptResponseData?, ApiError?) -> ()) {
        let url = "\(baseUrl)verifications"
        
        let model = CreateVerificationRequestBody.init(ts: timestamp, locale: locale)
        
        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try model.toDictionary()
        } catch {
            completion(nil, ApiError(errorText: "Error: Failed to convert model!"))
            return
        }
        
        AF.request(url, method: .post, parameters: jsonData, encoding: JSONEncoding.default)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationCreateAttemptResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, ApiError(errorText: response.error!.localizedDescription))
                return
            }
              if (response.data != nil && response.errorCode == 0) {
                  completion(response.data, nil)
              }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
          }
    }
    
    
    func initVerification(completion: @escaping (VerificationInitResponseData?, ApiError?) -> ()) {
        let url = "\(baseUrl)verifications/init"
        
        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .put, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationInitResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription))
                return
            }
              if (response.data != nil && response.errorCode == 0) {
                  completion(response.data, nil)
                  return
              }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")"))
                  return
              }
          }
    }
    
    
    func getCountries(completion: @escaping ([Country]?, ApiError?) -> ()) {
        let url = "\(baseUrl)countries"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: CountriesResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, ApiError(errorText: response.error!.localizedDescription))
                return
            }
              if (response.data != nil && response.errorCode == 0) {
                  completion(response.data, nil)
                  return
              }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
          }
    }
    
    
    func getCountryAvailableDocTypeInfo(countryCode: String,
                                        completion: @escaping ([DocTypeData]?, ApiError?) -> ()) {
        let url = "\(baseUrl)countries/\(countryCode)/documents"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: DocumentTypesForCountryResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, ApiError(errorText: response.error!.localizedDescription))
                return
            }
              if (response.data != nil && response.errorCode == 0) {
                  completion(response.data, nil)
              }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
          }
    }
    
    
    //https://stackoverflow.com/a/62407235/6405022  -- Alamofire + Multipart :
    
    func uploadVerificationDocuments(
        photo1: UIImage,
        photo2: UIImage?,
        countryCode: String,
        documentType: String,
        completion: @escaping (DocumentUploadResponseData?, ApiError?) -> ()) {
            
            let url = "\(baseUrl)documents"

            let token = LocalDatasource.shared.readAccessToken()
            if (token.isEmpty) {
                completion(nil, ApiError(errorText: "Error: cannot find access token"))
                return
            }
            let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))",
                                        "Content-Type" : "multipart/form-data"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(photo1.jpegData(compressionQuality: 0.9)!, withName: "0",
                                     fileName: "0.jpg", mimeType: "image/jpeg")
            if (photo2 != nil) {
                multipartFormData.append(photo2!.jpegData(compressionQuality: 0.9)!, withName: "1",
                                         fileName: "1.jpg", mimeType: "image/jpeg")
            } else {
                print("CLIENT: PHOTO 2 IS NIL")
            }
            multipartFormData.append(documentType.data(using: .utf8, allowLossyConversion: false)!, withName: "document_type")
            multipartFormData.append(countryCode.data(using: .utf8, allowLossyConversion: false)!, withName: "country")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers,
                      requestModifier: { $0.timeoutInterval = .infinity })
                .validate()
                .responseDecodable(of: DocumentUploadResponse.self) { (response) in
                    guard let response = response.value else {
                      //showing error on non-200 response code
                        completion(nil, ApiError(errorText: response.error!.localizedDescription))
                        return
                    }
                      if (response.data != nil && response.errorCode == 0) {
                          completion(response.data, nil)
                      }
                      if (response.errorCode != nil && response.errorCode != 0) {
                          completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                                   + "\(response.message ?? "")"))
                          return
                      }
                  }
    }
    
    
    func getDocumentInfo(documentId: Int,
                         completion: @escaping (PreProcessedDocData?, ApiError?) -> ()) {
        let url = "\(baseUrl)documents/\(documentId)"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .responseDecodable(of: PreProcessedDocumentResponse.self) { (response) in
            guard let response = response.value else {
            //showing error on non-200 response code
             completion(nil, ApiError(errorText: response.error!.localizedDescription))
             return
            }
            if (response.data != nil && response.errorCode == 0) {
               completion(response.data, nil)
            }
            if (response.errorCode != nil && response.errorCode != 0) {
               completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                        + "\(response.message ?? "")"))
               return
            }
        }
    }
    
    
    func updateAndConfirmDocInfo(documentId: Int,
                                 parsedDocFieldsData: ParsedDocFieldsData,
                                 completion: @escaping (Bool, ApiError?) -> ()) {
        let url = "\(baseUrl)documents/\(documentId)"
        
        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try parsedDocFieldsData.toDictionary()
        } catch {
            completion(false, ApiError(errorText: "Error: Failed to convert model!"))
            return
        }

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(false, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .put, parameters: jsonData, encoding: JSONEncoding.default, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .response(completionHandler: { (response) in
            guard response.value != nil else {
            //showing error on non-200 response code
             completion(false, ApiError(errorText: response.error!.localizedDescription))
             return
            }
            completion(true, nil)
            return
        })
    }
        
    
    func setDocumentAsPrimary(documentId: Int,
                              completion: @escaping (Bool, ApiError?) -> ()) {
        let url = "\(baseUrl)documents/\(documentId)/primary"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(false, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

         AF.request(url, method: .put, headers: headers)
         .validate()  //response returned an HTTP status code in the range 200–299
         .response(completionHandler: { (response) in
             guard response.value != nil else {
             //showing error on non-200 response code (?)
              completion(false, ApiError(errorText: response.error!.localizedDescription))
              return
             }
             completion(true, nil)
             return
         })
     }
    
    
    func uploadLivenessVideo(videoURL: String,
        completion: @escaping (Bool, ApiError?) -> ()) {
            
            let url = "\(baseUrl)liveness"

            let token = LocalDatasource.shared.readAccessToken()
            if (token.isEmpty) {
                completion(false, ApiError(errorText: "Error: cannot find access token"))
                return
            }
            let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(NSURL(fileURLWithPath: videoURL) as URL, withName: "video", fileName: "video", mimeType: "video/mp4")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
                .validate()
                .response(completionHandler: { (response) in
                    guard response.value != nil else {
                    //showing error on non-200 response code
                     completion(false, ApiError(errorText: response.error!.localizedDescription))
                     return
                    }
                    completion(true, nil)
                    return
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
