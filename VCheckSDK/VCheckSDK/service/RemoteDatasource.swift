//
//  DataService.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
@_implementationOnly import Alamofire
import UIKit

struct RemoteDatasource {
    
    // MARK: - Singleton
    static let shared = RemoteDatasource()
    
    // MARK: - URL
    private let verifBaseUrl = Constants.API.verificationApiBaseUrl
    private let partnerBaseUrl = Constants.API.partnerApiBaseUrl
    
    
    // MARK: - API calls
    
    func requestServerTimestamp(completion: @escaping (String?, ApiError?) -> ()) {
        let url = "\(verifBaseUrl)timestamp"
        
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

    func createVerificationRequest(timestamp: String,
                                   locale: String,
                                   verificationClientCreationModel: VerificationClientCreationModel,
                                   completion: @escaping (VerificationCreateAttemptResponseData?, ApiError?) -> ()) {
        let url = "\(partnerBaseUrl)verifications"
        
        //TODO: test creation properly!
        let model = CreateVerificationRequestBody.init(ts: timestamp, locale: locale, vModel: verificationClientCreationModel)
        
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
        let url = "\(verifBaseUrl)verifications/init"
        
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
    
    func getCurrentStage(completion: @escaping (StageResponse?, ApiError?) -> ()) {
        let url = "\(verifBaseUrl)stage/current"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, ApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: StageResponse.self) { (response) in
              guard let response = response.value else {
              //showing error on non-200 response code
               completion(nil, ApiError(errorText: response.error!.localizedDescription))
               return
              }
              if (response.data != nil && response.errorCode == 0) {
                 completion(response, nil)
              }
              if (response.errorCode != nil && response.errorCode != 0) {
                 completion(nil, ApiError(errorText: "\(String(describing: response.errorCode)): "
                                          + "\(response.message ?? "")"))
                 return
              }
          }
    }
    
    
    func getCountries(completion: @escaping ([Country]?, ApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/countries"

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
        //TODO: test!
        let url = "\(verifBaseUrl)documents/types?country=\(countryCode)"

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
        documentType: String, // TODO: rename to category = fields.Integer()
        completion: @escaping (DocumentUploadResponseData?, ApiError?) -> ()) {
            
            let url = "\(verifBaseUrl)documents/upload"

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
        let url = "\(verifBaseUrl)documents/\(documentId)/info"

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
        let url = "\(verifBaseUrl)documents/\(documentId)/confirm"
        
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
    
    
    func uploadLivenessVideo(videoFileURL: URL,
        completion: @escaping (LivenessUploadResponseData?, ApiError?) -> ()) {
            
            let url = "\(verifBaseUrl)liveness_challenges"

            let token = LocalDatasource.shared.readAccessToken()
            if (token.isEmpty) {
                completion(nil, ApiError(errorText: "Error: cannot find access token"))
                return
            }
            let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(videoFileURL, withName: "video.mp4", fileName: "video", mimeType: "video/mp4")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
                .validate()
                .responseDecodable(of: LivenessUploadResponse.self) { (response) in
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


// Just for test:
//    func getCurrentStage(completion: @escaping (StageResponse?, ApiError?) -> ()) {
//        let type = Int.random(in: (0...1))
//        if (Int.random(in: (0...1)) == 1) {
//            completion(StageResponse.init(data: StageResponseData.init(id: 0, type: type),
//                       errorCode: 1, message: "USER_INTERACTED_COMPLETED"), nil)
//        } else {
//            completion(StageResponse.init(data: StageResponseData.init(id: 0, type: type),
//                       errorCode: 0, message: "VERIFICATION_NOT_INITIALIZED"), nil)
//        }
//    }

//    func setDocumentAsPrimary(documentId: Int,
//                              completion: @escaping (Bool, ApiError?) -> ()) {
//        let url = "\(verifBaseUrl)documents/\(documentId)/primary"
//
//        let token = LocalDatasource.shared.readAccessToken()
//        if (token.isEmpty) {
//            completion(false, ApiError(errorText: "Error: cannot find access token"))
//            return
//        }
//        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
//
//         AF.request(url, method: .put, headers: headers)
//         .validate()  //response returned an HTTP status code in the range 200–299
//         .response(completionHandler: { (response) in
//             guard response.value != nil else {
//             //showing error on non-200 response code (?)
//              completion(false, ApiError(errorText: response.error!.localizedDescription))
//              return
//             }
//             completion(true, nil)
//             return
//         })
//     }
