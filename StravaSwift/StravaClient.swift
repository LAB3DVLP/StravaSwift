//
//  StravaClient.swift
//  StravaSwift
//
//  Created by Matthew on 11/11/2015.
//  Copyright © 2015 Matthew Clarkson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 StravaClient responsible for making all api requests
*/
public class StravaClient {
    
    /**
     Access the shared instance
     */
    public static let sharedInstance = StravaClient()
    
    private init() {}
    private var config: StravaConfig?
    
    /** 
      The OAuthToken returned by the delegate
     **/
    public var token:  OAuthToken? { return config?.delegate.get() }
    
    internal var authParams: [String: AnyObject] {
        return [
            "client_id" : config?.clientId ?? 0,
            "redirect_uri" : config?.redirectUri ?? "",
            "scope" : config?.scope.rawValue ?? "",
            "state" : "ios",
            "approval_prompt" : "force",
            "response_type" : "code"
        ]
    }
    
    internal func tokenParams(code: String) -> [String:AnyObject]  {
        return [
            "client_id" : config?.clientId ?? 0,
            "client_secret" : config?.clientSecret ?? "",
            "code" : code
        ]
    }
}

//MARK:varConfig

extension StravaClient {

    /**
     Initialize the shared instance with your credentials. You must use this otherwise fatal errors will be 
     returned when making api requests.
     
     - Parameter config: a StravaConfig struct
     - Returns: An instance of self (i.e. StravaClient)
     */
    public func initWithConfig(config: StravaConfig) -> StravaClient {
        self.config = config
        
        return self
    }
}

//MARK : - Auth

extension StravaClient {
    
    /**
     Opens the Strava OAuth web page in mobile Safari for the user to authorize the application.
     **/
    public func authorize() {
        UIApplication.sharedApplication().openURL(Router.authorizationUrl)
    }
    
    /**
    Helper method to get the code from the redirection from Strava after the user has authorized the application (useful in AppDelegate)
     
     - Parameter: url
     - Returns: the OAuth code
     **/
    public func handleAuthorizationRedirect(url: NSURL) -> String?  {
        return url.getQueryParameters()?["code"]
    }
    
    /**
     Get an OAuth token from Strava
     
     - Parameter code: the code (string) returned from strava
     - Parameter result: a closure to handle the OAuthToken
     **/
    public func getAccessToken(code: String, result: ((OAuthToken)? -> Void)) {
        oauthRequest(Router.Token(code: code))?.responseStrava { [weak self] (response: Response<OAuthToken, NSError>) in
            guard let `self` = self else { return }
            let token = response.result.value
            self.config?.delegate.set(token)
            result(token)
        }
    }
}


//MARK: - Athlete

extension StravaClient {

    /**
     Request a single object from the Strava Api
     
     - Parameter route: a Router enum case which may require parameters
     - Parameter result: a closure to handle the returned object
     **/
    public func request<T: Strava>(route: Router, result: ((T)? -> Void)) {
        switch route {
//        case .Upload(let upload):
//            oauthUpload(route.URLRequest, upload: upload)?.responseStrava { (response: Response<T, NSError>) in
//                result(response.result.value)
//            }
        default:
            oauthRequest(route)?.responseStrava { (response: Response<T, NSError>) in
                result(response.result.value)
            }
        }
   }
    
    /**
     Request an array of objects from the Strava Api
     
     - Parameter route: a Router enum case which may require parameters
     - Parameter result: a closure to handle the returned objects
     **/
    public func request<T: Strava>(route: Router, result: (([T])? -> Void)) {
        oauthRequest(route)?.responseStravaArray { (response: Response<[T], NSError>) in
            result(response.result.value)
        }
    }
    
}

extension StravaClient {
    
    private func isConfigured() -> (Bool, StravaClientError?) {
        if config == nil {
            return (false, StravaClientError.InvalidCredentials)
        }
        
        return (true, nil)
    }
    
    private func checkConfiguration() {
        let (_, error) = StravaClient.sharedInstance.isConfigured()
        
        if let _ = error {
            fatalError("Strava client is not configured")
        }

    }
    
    private func oauthRequest(URLRequest: URLRequestConvertible) -> Request? {
        checkConfiguration()
        
        return Alamofire.Manager.sharedInstance.request(URLRequest.URLRequest)
    }
//    
//    private func oauthUpload(URLRequest: URLRequestConvertible, upload: Upload) -> Request? {
//        checkConfiguration()
//        
//                guard let url = URLRequest.URLRequest.URL else { return nil }
//        
//                return Alamofire.Manager.sharedInstance.upload(.POST, url,
//                    headers: URLRequest.URLRequest.allHTTPHeaderFields,
//                    multipartFormData: { multipartFormData in
//        
//                        multipartFormData.appendBodyPart(data: upload.file, name: "file.gpx")
//                        for (key, value) in upload.params {
//                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
//                        }
//                    },
//                    encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
//                    encodingCompletion: { encodingResult in
//                        switch encodingResult {
//                        case .Success(let upload, _, _):
//                            upload.responseJSON { response in
//                                debugPrint(response)
//                            }
//                        case .Failure(let encodingError):
//                            print(encodingError)
//                        }
//                })
//    }

}