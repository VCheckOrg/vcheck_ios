//
//  DataService.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
@_implementationOnly import Alamofire
import UIKit

//TODO: rename to VCheckLocalDatasource!
struct RemoteDatasource {
    
    // MARK: - Singleton
    static let shared = RemoteDatasource()
    
    // MARK: - URL
    private let verifBaseUrl = Constants.API.verificationApiBaseUrl
    private let partnerBaseUrl = Constants.API.partnerApiBaseUrl
    
    
    // MARK: - API calls
    
    func requestServerTimestamp(completion: @escaping (String?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)timestamp"
        
        AF.request(url, method: .get)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseString(completionHandler: { (response) in
            guard let timestamp = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, VCheckApiError(errorText: "requestServerTimestamp: " + response.error!.localizedDescription))
                return
            }
              completion(timestamp, nil)
              return
          })
    }

    func createVerificationRequest(timestamp: String,
                                   locale: String,
                                   verificationClientCreationModel: VerificationClientCreationModel,
                                   completion: @escaping (VerificationCreateAttemptResponseData?, VCheckApiError?) -> ()) {
        let url = "\(partnerBaseUrl)verifications"
        
        let model = CreateVerificationRequestBody.init(ts: timestamp, locale: locale, vModel: verificationClientCreationModel)
                
        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try model.toDictionary()
        } catch {
            completion(nil, VCheckApiError(errorText: "Error: Failed to convert model!"))
            return
        }
        
        AF.request(url, method: .post, parameters: jsonData, encoding: JSONEncoding.default)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationCreateAttemptResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, VCheckApiError(errorText: "createVerificationRequest: " + response.error!.localizedDescription))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
              completion(response.data, nil)
          }
    }
    
    
    func initVerification(completion: @escaping (VerificationInitResponseData?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)verifications/init"
        
        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .put, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationInitResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code (?)
                completion(nil, VCheckApiError(errorText: "initVerification: " + response.error!.localizedDescription))
                return
            }
            if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")"))
                return
            }
            completion(response.data, nil)
          }
    }
    
    func getCurrentStage(completion: @escaping (StageResponse?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)stages/current"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: StageResponse.self) { (response) in
              guard let response = response.value else {
              //showing error on non-200 response code
               completion(nil, VCheckApiError(errorText: "getCurrentStage: " +  response.error!.localizedDescription))
               return
              }
              completion(response, nil)
              //print("======= CLIENT:  GET CURRENT STAGE - response data: \(String(describing: response))")
          }
    }
    
    
    func getCountries(completion: @escaping ([Country]?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/countries"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: CountriesResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, VCheckApiError(errorText: "getCountries: " +  response.error!.localizedDescription))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
              completion(response.data, nil)
          }
    }
    
    
    func getCountryAvailableDocTypeInfo(countryCode: String,
                                        completion: @escaping ([DocTypeData]?, VCheckApiError?) -> ()) {

        let url = "\(verifBaseUrl)documents/types?country=\(countryCode)"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: DocumentTypesForCountryResponse.self) { (response) in
            guard let response = response.value else {
              //showing error on non-200 response code
                completion(nil, VCheckApiError(errorText: "getCountryAvailableDocTypeInfo: " + response.error!.localizedDescription))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")"))
                  return
              }
              completion(response.data, nil)
          }
    }
    
    
    //https://stackoverflow.com/a/62407235/6405022  -- Alamofire + Multipart :
    
    func uploadVerificationDocuments(
        photo1: UIImage,
        photo2: UIImage?,
        countryCode: String,
        category: String,
        completion: @escaping (DocumentUploadResponse?, VCheckApiError?) -> ()) {
            
            let url = "\(verifBaseUrl)documents/upload"

            let token = LocalDatasource.shared.readAccessToken()
            if (token.isEmpty) {
                completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
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
            multipartFormData.append(category.data(using: .utf8, allowLossyConversion: false)!, withName: "category")
            multipartFormData.append(countryCode.data(using: .utf8, allowLossyConversion: false)!, withName: "country")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers,
                      requestModifier: { $0.timeoutInterval = .infinity })
                .validate()
                .responseDecodable(of: DocumentUploadResponse.self) { (response) in
                    guard let response = response.value else {
                      //showing error on non-200 response code
                        completion(nil, VCheckApiError(errorText: "uploadVerificationDocuments: " + response.error!.localizedDescription))
                        return
                    }
                    completion(response, nil)
                  }
            
    }
    
    
    func getDocumentInfo(documentId: Int,
                         completion: @escaping (PreProcessedDocData?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/\(documentId)/info"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .responseDecodable(of: PreProcessedDocumentResponse.self) { (response) in
            guard let response = response.value else {
            //showing error on non-200 response code
             completion(nil, VCheckApiError(errorText: "getDocumentInfo: " + response.error!.localizedDescription))
             return
            }
            if (response.errorCode != nil && response.errorCode != 0) {
               completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                        + "\(response.message ?? "")"))
               return
            }
            completion(response.data, nil)
        }
    }
    
    
    func updateAndConfirmDocInfo(documentId: Int,
                                 parsedDocFieldsData: DocUserDataRequestBody,
                                 completion: @escaping (Bool, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/\(documentId)/confirm"
        
        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try parsedDocFieldsData.toDictionary()
        } catch {
            completion(false, VCheckApiError(errorText: "Error: Failed to convert model!"))
            return
        }

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(false, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .put, parameters: jsonData, encoding: JSONEncoding.default, headers: headers)
        .validate()  //response returned an HTTP status code in the range 200–299
        .response(completionHandler: { (response) in
            guard response.value != nil else {
            //showing error on non-200 response code
             completion(false, VCheckApiError(errorText: "updateAndConfirmDocInfo" + response.error!.localizedDescription))
             return
            }
            completion(true, nil)
            return
        })
    }
    
    
    func uploadLivenessVideo(videoFileURL: URL,
        completion: @escaping (LivenessUploadResponseData?, VCheckApiError?) -> ()) {
            
            let url = "\(verifBaseUrl)liveness_challenges"

            let token = LocalDatasource.shared.readAccessToken()
            if (token.isEmpty) {
                completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
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
                     completion(nil, VCheckApiError(errorText: "uploadLivenessVideo" + response.error!.localizedDescription))
                     return
                    }
                    if (response.errorCode != nil && response.errorCode != 0) {
                       completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                                + "\(response.message ?? "")"))
                       return
                    }
                    completion(response.data, nil)
                }
    }
    
    
    func sendLivenessGestureAttempt(frameImage: UIImage,
                                    gesture: String,
                                    completion: @escaping (LivenessGestureResponse?, VCheckApiError?) -> ()) {
        
        let url = "\(verifBaseUrl)liveness_challenges/gesture"

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
            
        let multipartFormData = MultipartFormData.init()
        
        multipartFormData.append(frameImage.jpegData(compressionQuality: 0.7)!, withName: "image",
                                 fileName: "image.jpg", mimeType: "image/jpeg")
        multipartFormData.append(gesture.data(using: .utf8, allowLossyConversion: false)!, withName: "gesture")
        
        //print("===== SENDING REQUEST FOR GESTURE: \(gesture)")
        
        AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
            .validate()
            .responseDecodable(of: LivenessGestureResponse.self) { (response) in
                guard let response = response.value else {
                //showing error on non-200 response code
                 completion(nil, VCheckApiError(errorText: "uploadLivenessVideo" + response.error!.localizedDescription))
                 return
                }
                if (response.errorCode != nil && response.errorCode != 0) {
                   completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")"))
                   return
                }
                completion(response, nil)
            }
    }
    
    
    func checkFinalVerificationStatus(verifToken: String,
                                      verifId: Int,
                                      partnerId: Int,
                                      partnerSecret: String,
                                      completion: @escaping (VerificationCheckResult?, VCheckApiError?) -> ()) {

        let token = LocalDatasource.shared.readAccessToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token"))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        requestServerTimestamp(completion: { (timestamp, error) in
            if error != nil {
                completion(nil, VCheckApiError(errorText: "Error: Service timestamp was not retrieved"))
                return
            } else {
                let sign = "\(partnerId)\(timestamp!)\(verifId)\(partnerSecret)".sha256()
                let url = "\(partnerBaseUrl)verifications/\(verifId)?partner_id=\(partnerId)&timestamp=\(timestamp!)&sign=\(sign)"
                
                AF.request(url, method: .get, headers: headers)
                  .validate()  //response returned an HTTP status code in the range 200–299
                  .responseDecodable(of: FinalVerifCheckResponseModel.self) { (response) in
                    guard let response = response.value else {
                      //showing error on non-200 response code
                        completion(nil, VCheckApiError(errorText: "getCountryAvailableDocTypeInfo: " + response.error!.localizedDescription))
                        return
                    }
                      if (response.errorCode != nil && response.errorCode != 0) {
                          completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                                   + "\(response.message ?? "")"))
                          return
                      }
                      let result = VerificationCheckResult.init(fromData: response.data!)
                      completion(result, nil)
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
