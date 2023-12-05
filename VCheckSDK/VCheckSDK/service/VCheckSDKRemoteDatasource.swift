//
//  DataService.swift
//  VcheckSDKDemoIOS
//
//  Created by Kirill Kaun on 28.04.2022.
//

import Foundation
@_implementationOnly import Alamofire
import UIKit

struct VCheckSDKRemoteDatasource {
    
    // MARK: - Singleton
    static let shared = VCheckSDKRemoteDatasource()
    
    // MARK: - URL
    private var verifBaseUrl: URL
    
    init() {
        if (VCheckSDK.shared.getEnvironment() == VCheckEnvironment.DEV) {
            verifBaseUrl = VCheckSDKConstants.API.devVerificationApiBaseUrl
        } else {
            verifBaseUrl = VCheckSDKConstants.API.partnerVerificationApiBaseUrl
        }
    }
    
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
    
    func getProviders(completion: @escaping (ProvidersResponse?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)providers"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: ProvidersResponse.self) { (response) in
              guard let response = response.value else {
               completion(nil, VCheckApiError(errorText: "getProviders: " +  response.error!.localizedDescription,
                                              errorCode: response.response?.statusCode))
               return
              }
              checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
              completion(response, nil)
              return
          }
    }
    
    func initProvider(initProviderRequestBody: InitProviderRequestBody,
                      completion: @escaping (Bool, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)providers/init"
                
        var jsonData: Dictionary<String, Any>?
        do {
            jsonData = try initProviderRequestBody.toDictionary()
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
        //.validate()  //response returned an HTTP status code in the range 200–299
        //validation is removed for logical reasons
            .response(completionHandler: { (response) in
            guard response.value != nil else {
                completion(false, VCheckApiError(errorText: "initProvider: " + response.error!.localizedDescription,
                                               errorCode: response.response?.statusCode))
                return
            }
            completion(true, nil)
            return
          })
    }
    
    func getPriorityCountries(completion: @escaping (PriorityCountries?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)providers/priority_countries"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: PriorityCountries.self) { (response) in
              guard let response = response.value else {
               completion(nil, VCheckApiError(errorText: "getProviders: " +  response.error!.localizedDescription,
                                              errorCode: response.response?.statusCode))
               return
              }
              checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
              completion(response, nil)
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
          //.validate()  //response returned an HTTP status code in the range 200–299 //!
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
            checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
            completion(response.data, nil)
            return
          }
    }
    
    func getCurrentStage(checkStageError: Bool, completion: @escaping (StageResponse?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)stages/current"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]

        AF.request(url, method: .get, headers: headers)
          .responseDecodable(of: StageResponse.self) { (resp) in
              guard let dataResponse = resp.value else {
                  completion(nil, VCheckApiError(errorText: "getCurrentStage: " +  resp.error!.localizedDescription,
                                              errorCode: resp.response?.statusCode))
                  return
              }
              if (checkStageError == true && resp.response?.statusCode != 200) {
                  checkStageErrorForResult(errorCode: dataResponse.errorCode)
              }
              completion(dataResponse, nil)
              return
          }
    }
    
    func getAvailableDocTypes(countryCode: String,
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
              checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
              completion(response.data, nil)
              return
          }
    }
    
    
    func uploadVerificationDocuments(
        photo1: UIImage,
        photo2: UIImage?,
        countryCode: String,
        category: String,
        manual: Bool,
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
                
            multipartFormData.append(photo1.jpegData(compressionQuality: 0.8)!, withName: "0",
                                     fileName: "0.jpg", mimeType: "image/jpeg")
            if (photo2 != nil) {
                multipartFormData.append(photo2!.jpegData(compressionQuality: 0.8)!, withName: "1",
                                         fileName: "1.jpg", mimeType: "image/jpeg")
            }
            multipartFormData.append(category.data(using: .utf8, allowLossyConversion: false)!, withName: "category")
            multipartFormData.append(countryCode.data(using: .utf8, allowLossyConversion: false)!, withName: "country")
            multipartFormData.append(String(manual).data(using: .utf8, allowLossyConversion: false)!, withName: "manual")
                
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers,
                      requestModifier: { $0.timeoutInterval = .infinity })
                .responseDecodable(of: DocumentUploadResponse.self) { (response) in
                    guard let resp = response.value else {
                        completion(nil, VCheckApiError(errorText: "uploadVerificationDocuments: "
                                                       + response.error!.localizedDescription,
                                                       errorCode: response.response?.statusCode))
                        return
                    }
                    if (response.response?.statusCode != 200) {
                        completion(resp, VCheckApiError(errorText: response.value?.message ?? "Error",
                                                         errorCode: response.response?.statusCode))
                        return
                    }
                    completion(resp, nil)
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
            checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
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
            .responseDecodable(of: ConfirmDocumentResponse.self) { (response) in
            guard response.value != nil else {
             completion(false, VCheckApiError(errorText: "updateAndConfirmDocInfo" + response.error!.localizedDescription,
                                              errorCode: response.response?.statusCode))
             return
            }
            if (response.response?.statusCode != 200) {
                completion(false, VCheckApiError(errorText: response.value?.message ?? "Error",
                                                 errorCode: response.value?.errorCode))
                return
            }
            completion(true, nil)
            return
        }
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
                    checkIfUserInteractionCompletedForResult(errorCode: response.errorCode)
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
        
        
        
        multipartFormData.append(frameImage.jpegData(compressionQuality: 1.0)!, withName: "image",
                                 fileName: "image.jpg", mimeType: "image/jpeg")
        multipartFormData.append(gesture.data(using: .utf8, allowLossyConversion: false)!, withName: "gesture")
                
        AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
            .responseDecodable(of: LivenessGestureResponse.self) { (response) in
                guard let response = response.value else {
                 completion(nil, VCheckApiError(errorText: "sendLivenessGestureAttempt" + response.error!.localizedDescription,
                                                errorCode: response.response?.statusCode))
                 return
                }
                if (response.errorCode != nil && response.errorCode != 0) {
                   completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")",
                                                  errorCode: response.errorCode))
                   return
                }
                // here, we're not checking result with checkIfUserInteractionCompleted(errorCode: response.errorCode)
                completion(response, nil)
                return
            }
    }
    
    
    func sendSegmentationDocAttempt(frameImage: UIImage,
            country: String,
            category: String, //Int
            index: String, //Int
            completion: @escaping (SegmentationGestureResponse?, VCheckApiError?) -> ()) {
        let url = "\(verifBaseUrl)documents/inspect"

        let token = VCheckSDK.shared.getVerificationToken()
        if (token.isEmpty) {
            completion(nil, VCheckApiError(errorText: "Error: cannot find access token",
                                           errorCode: VCheckApiError.DEFAULT_CODE))
            return
        }
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(String(describing: token))"]
            
        let multipartFormData = MultipartFormData.init()
        
        multipartFormData.append(frameImage.jpegData(compressionQuality: 1.0)!, withName: "image",
                                 fileName: "image.jpg", mimeType: "image/jpeg")
        
        multipartFormData.append(country.data(using: .utf8, allowLossyConversion: false)!, withName: "country")
        multipartFormData.append(category.data(using: .utf8, allowLossyConversion: false)!, withName: "category")
        multipartFormData.append(index.data(using: .utf8, allowLossyConversion: false)!, withName: "index")
                
        AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers)
            .responseDecodable(of: SegmentationGestureResponse.self) { (response) in
                guard let response = response.value else {
                 completion(nil, VCheckApiError(errorText: "sendSegmentationDocAttempt" + response.error!.localizedDescription,
                                                errorCode: response.response?.statusCode))
                 return
                }
                if (response.errorCode != nil && response.errorCode != 0) {
                   completion(nil, VCheckApiError(errorText: "\(String(describing: response.errorCode)): "
                                            + "\(response.message ?? "")",
                                                  errorCode: response.errorCode))
                   return
                }
                // here, we're not checking result with checkIfUserInteractionCompleted(errorCode: response.errorCode)
                completion(response, nil)
                return
            }
    }
    
    //if global 400, then close SDK
    //otherwise, depends on specific case
    func checkIfUserInteractionCompletedForResult(errorCode: Int?) {
        if (errorCode == BaseClientErrors.USER_INTERACTED_COMPLETED) {
            VCheckSDK.shared.setIsVerificationExpired(isExpired: true)
            VCheckSDK.shared.finish(executePartnerCallback: false)
        } else {
            return
        }
    }
    
    func checkStageErrorForResult(errorCode: Int?) {
        print("Stage check error code: \(String(describing: errorCode))")
        if (errorCode != nil
            && errorCode! > StageErrorType.VERIFICATION_NOT_INITIALIZED.toTypeIdx()) {
            VCheckSDK.shared.setIsVerificationExpired(isExpired: true)
            VCheckSDK.shared.finish(executePartnerCallback: false)
        } else {
            return
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
