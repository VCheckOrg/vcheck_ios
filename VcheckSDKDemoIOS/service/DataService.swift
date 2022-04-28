//
//  DataService.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
import Alamofire

struct DataService {
    
    // MARK: - Singleton
    static let shared = DataService()
    
    // MARK: - URL
    private let baseUrl = Constants.API.serviceBaseURL
    
    
    // MARK: - Services
    
    func requestServerTimestamp(completion: @escaping (String?, ApiError?) -> ()) {
        let url = "\(baseUrl)timestmap"
        
        AF.request(url, method: .get)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseString(completionHandler: { (response) in
            guard let timestamp = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
                return
            }
              completion(timestamp, nil)
              return
          })
    }
    
    
    func createVerificationRequest(completion: @escaping (VerificationCreateAttemptResponseData?, ApiError?) -> ()) {
        let url = "\(baseUrl)verifications"
        
        AF.request(url, method: .post)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationCreateAttemptResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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

        let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]
        
        AF.request(url, method: .put, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationInitResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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

        let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: CountriesResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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

        let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: DocumentTypesForCountryResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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
    
    
    //https://stackoverflow.com/a/62407235/6405022  -- Alamofire + Multipart
    
    func uploadVerificationDocuments(
        photo1: UIImage,
        photo2: UIImage?,
        countryCode: String,
        documentType: String,
        completion: @escaping ([DocTypeData]?, ApiError?) -> ()) {
            
            let url = "\(baseUrl)documents"

            let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(documentType.data(using: .utf8, allowLossyConversion: false)!, withName: "document_type")
            multipartFormData.append(countryCode.data(using: .utf8, allowLossyConversion: false)!, withName: "country")
            multipartFormData.append(photo1.jpegData(compressionQuality: 0.7)!, withName: "photo1")
            if (photo2 != nil) {
                multipartFormData.append(photo2!.jpegData(compressionQuality: 0.7)!, withName: "photo2")
            }
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
                .validate()
                .responseDecodable(of: DocumentUploadResponse.self) { (response) in
                    guard let response = response.value else {
                      //showing error on non-200 response code (?)
                        completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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
        let url = "documents/\(documentId)"

        let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]

        AF.request(url, method: .get, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .responseDecodable(of: PreProcessedDocumentResponse.self) { (response) in
            guard let response = response.value else {
            //showing error on non-200 response code (?)
             completion(nil, ApiError(errorText: response.error!.localizedDescription)) //test
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
                                 parsedDocFieldsData: ParsedData,
                                 completion: @escaping (Bool, ApiError?) -> ()) {
        let url = "documents/\(documentId)"

        let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]

        AF.request(url, method: .put, parameters: parsedDocFieldsData, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .response(completionHandler: { (response) in
            guard response.value != nil else {
            //showing error on non-200 response code (?)
             completion(false, ApiError(errorText: response.error!.localizedDescription)) //test
             return
            }
            completion(true, nil)
            return
        })
    }
        
    
    func setDocumentAsPrimary(documentId: Int,
                              completion: @escaping (Bool, ApiError?) -> ()) {
         let url = "documents/\(documentId)/primary"

         let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]

         AF.request(url, method: .put, headers: headers)
         .validate()  //response returned an HTTP status code in the range 200–299
         .response(completionHandler: { (response) in
             guard response.value != nil else {
             //showing error on non-200 response code (?)
              completion(false, ApiError(errorText: response.error!.localizedDescription)) //test
              return
             }
             completion(true, nil)
             return
         })
     }
    
    
    func uploadLivenessVideo(videoURL: String,
        completion: @escaping (Bool, ApiError?) -> ()) {
            
            let url = "\(baseUrl)liveness"

            let headers: HTTPHeaders = ["Authorization" : "Bearer: \(KeychainHelper.shared.readAccessToken())"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(NSURL(fileURLWithPath: videoURL) as URL, withName: "video", fileName: "video", mimeType: "video/mp4")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
                .validate()
                .response(completionHandler: { (response) in
                    guard response.value != nil else {
                    //showing error on non-200 response code (?)
                     completion(false, ApiError(errorText: response.error!.localizedDescription)) //test
                     return
                    }
                    completion(true, nil)
                    return
                })
    }
    
}
