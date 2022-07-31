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
struct VCheckSDKRemoteDatasource {
    
    // MARK: - Singleton
    static let shared = VCheckSDKRemoteDatasource()
    
    // MARK: - URL
    private let verifBaseUrl = VCheckSDKConstants.API.verificationApiBaseUrl
    private let partnerBaseUrl = VCheckSDKConstants.API.partnerApiBaseUrl
    
    
    // MARK: - API calls
    
    func requestServerTimestamp(completion: @escaping (String?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)timestamp"
        
        AF.request(url, method: .get)
          .responseString(completionHandler: { (response) in
            guard let timestamp = response.value else {
                completion(nil, VCheckApiError(errorText: "requestServerTimestamp: " + response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
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
            completion(nil, VCheckApiError(errorText: "Error: Failed to convert model!",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        
        AF.request(url, method: .post, parameters: jsonData, encoding: JSONEncoding.default)
          .responseDecodable(of: VerificationCreateAttemptResponse.self) { (response) in
            guard let response = response.value else {
                completion(nil, VCheckApiError(errorText: "createVerificationRequest: " + response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")",
                                                 errorCode: response.errorCode))
                  return
              }
              completion(response.data, nil)
              return
          }
    }
    
    
    func initVerification(completion: @escaping (VerificationInitResponseData?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)verifications/init"
        
        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .put, headers: headers)
          .validate()  //response returned an HTTP status code in the range 200–299
          .responseDecodable(of: VerificationInitResponse.self) { (response) in
            guard let response = response.value else {
                completion(nil, VCheckApiError(errorText: "initVerification: " + response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
                return
            }
            if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")",
                                                 errorCode: response.errorCode))
                return
            }
            completion(response.data, nil)
            return
          }
    }
    
    func getCurrentStage(completion: @escaping (StageResponse?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)stages/current"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: StageResponse.self) { (response) in
              guard let response = response.value else {
               completion(nil, VCheckApiError(errorText: "getCurrentStage: " +  response.error!.localizedDescription,
                                              errorCode: response.response?.statusCode))
               return
              }
              completion(response, nil)
              return
              //print("======= CLIENT:  GET CURRENT STAGE - response data: \(String(describing: response))")
          }
    }
    
    
    func getCountries(completion: @escaping ([Country]?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/countries"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: CountriesResponse.self) { (response) in
            guard let response = response.value else {
                completion(nil, VCheckApiError(errorText: "getCountries: " +  response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")",
                                                 errorCode: response.errorCode))
                  return
              }
              completion(response.data, nil)
              return
          }
    }
    
    
    func getCountryAvailableDocTypeInfo(countryCode: String,
                                        completion: @escaping ([DocTypeData]?, VCheckApiError?) -> ()) {

        let url = "\(verifBaseUrl)documents/types?country=\(countryCode)"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: DocumentTypesForCountryResponse.self) { (response) in
            guard let response = response.value else {
                completion(nil, VCheckApiError(errorText: "getCountryAvailableDocTypeInfo: " + response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
                return
            }
              if (response.errorCode != nil && response.errorCode != 0) {
                  completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                           + "\(response.message ?? "")",
                                                 errorCode: response.errorCode))
                  return
              }
              completion(response.data, nil)
              return
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

            let token = VCheckSDK.shared.getVerificationToken()
            if (token.isEmpty) {
                completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                               errorCode: VCheckApiError.DEFAULT_CODE))
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
                .responseDecodable(of: DocumentUploadResponse.self) { (response) in
                    guard let response = response.value else {
                        completion(nil, VCheckApiError(errorText: "uploadVerificationDocuments: "
                                                       + response.error!.localizedDescription,
                                                       errorCode: response.response?.statusCode))
                        return
                    }
                    completion(response, nil)
                    return
                  }
    }
    
    
    func getDocumentInfo(documentId: Int,
                         completion: @escaping (PreProcessedDocData?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/\(documentId)/info"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
        .responseDecodable(of: PreProcessedDocumentResponse.self) { (response) in
            guard let response = response.value else {
             completion(nil, VCheckApiError(errorText: "getDocumentInfo: " + response.error!.localizedDescription,
                                            errorCode: response.response?.statusCode))
             return
            }
            if (response.errorCode != nil && response.errorCode != 0) {
               completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                        + "\(response.message ?? "")",
                                              errorCode: response.errorCode))
               return
            }
            completion(response.data, nil)
            return
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
            completion(false, VCheckApiError(errorText: "Error: Failed to convert model!",
                                             errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(false, VCheckApiError(errorText: "Error: cannot find access token",
                                             errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .put, parameters: jsonData, encoding: JSONEncoding.default, headers: headers)
        .response(completionHandler: { (response) in
            guard response.value != nil else {
             completion(false, VCheckApiError(errorText: "updateAndConfirmDocInfo" + response.error!.localizedDescription,
                                              errorCode: response.response?.statusCode))
             return
            }
            completion(true, nil)
            return
        })
    }
    
    
    func uploadLivenessVideo(videoFileURL: URL,
        completion: @escaping (LivenessUploadResponseData?, VCheckApiError?) -> ()) {
            
            let url = "\(verifBaseUrl)liveness_challenges"

            let token = VCheckSDK.shared.getVerificationToken()
            if (token.isEmpty) {
                completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                               errorCode: VCheckApiError.DEFAULT_CODE))
                return
            }
            let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
                
            let multipartFormData = MultipartFormData.init()
                
            multipartFormData.append(videoFileURL, withName: "video.mp4", fileName: "video", mimeType: "video/mp4")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
                .responseDecodable(of: LivenessUploadResponse.self) { (response) in
                    guard let response = response.value else {
                     completion(nil, VCheckApiError(errorText: "uploadLivenessVideo" + response.error!.localizedDescription,
                                                    errorCode: response.response?.statusCode))
                     return
                    }
                    if (response.errorCode != nil && response.errorCode != 0) {
                       completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                                + "\(response.message ?? "")",
                                                      errorCode: response.errorCode))
                       return
                    }
                    completion(response.data, nil)
                    return
                }
    }
    
    
    func sendLivenessGestureAttempt(frameImage: UIImage,
                                    gesture: String,
                                    completion: @escaping (LivenessGestureResponse?, VCheckApiError?) -> ()) {
        
        let url = "\(verifBaseUrl)liveness_challenges/gesture"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
            
        let multipartFormData = MultipartFormData.init()
        
        multipartFormData.append(frameImage.jpegData(compressionQuality: 0.5)!, withName: "image",
                                 fileName: "image.jpg", mimeType: "image/jpeg")
        multipartFormData.append(gesture.data(using: .utf8, allowLossyConversion: false)!, withName: "gesture")
        
        //print("===== SENDING REQUEST FOR GESTURE: \(gesture)")
        
        AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
            .responseDecodable(of: LivenessGestureResponse.self) { (response) in
                guard let response = response.value else {
                 completion(nil, VCheckApiError(errorText: "uploadLivenessVideo" + response.error!.localizedDescription,
                                                errorCode: response.response?.statusCode))
                 return
                }
                if (response.errorCode != nil && response.errorCode != 0) {
                   completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")",
                                                  errorCode: response.errorCode))
                   return
                }
                //print("GESTURE RESPONSE -- DATA: \(String(describing: response))")
                completion(response, nil)
                return
            }
    }
    
    
    func checkFinalVerificationStatus(verifToken: String,
                                      verifId: Int,
                                      partnerId: Int,
                                      partnerSecret: String,
                                      completion: @escaping (FinalVerifCheckResponseModel?, VCheckApiError?) -> ()) {

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
        
        requestServerTimestamp(completion: { (timestamp, error) in
            if error != nil {
                completion(nil, VCheckApiError(errorText: "Error: Service timestamp was not retrieved",
                                               errorCode: VCheckApiError.DEFAULT_CODE))
                return
            } else {
                let sign = "\(partnerId)\(timestamp!)\(verifId)\(partnerSecret)".sha256()
                let url = "\(partnerBaseUrl)verifications/\(verifId)?partner_id=\(partnerId)&timestamp=\(timestamp!)&sign=\(sign)"
                
                AF.request(url, method: .get, headers: headers)
                  .responseDecodable(of: FinalVerifCheckResponseModel.self) { (response) in
                    guard let response = response.value else {
                        completion(nil, VCheckApiError(errorText: "getCountryAvailableDocTypeInfo: "
                                                       + response.error!.localizedDescription,
                                                       errorCode: response.response?.statusCode))
                        return
                    }
                      if (response.errorCode != nil && response.errorCode != 0) {
                          completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                                   + "\(response.message ?? "")",
                                                         errorCode: response.errorCode))
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
