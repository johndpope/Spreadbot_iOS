//
//  AlamofireAuthHandler.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxSwiftExt
import Locksmith

class AlamofireAuthHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private let spreadbotServerCredsDictionary = Locksmith.loadDataForUserAccount(userAccount: "spreadbotServerCreds")
    
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    public init() {
        if let baseURL = ProcessInfo.processInfo.environment["SPREADBOT_AUTH_URL"] {
            baseURLString = baseURL
        } else {
            baseURLString = "http://localhost:8080/raw"
        }
        
        if let authTkn = spreadbotServerCredsDictionary?["accessToken"] as? String {
            accessToken = authTkn
        } else {
            accessToken = "pleaseUpdateMe!"
        }
        
        if let refreshTkn = spreadbotServerCredsDictionary?["refreshToken"] as? String {
            refreshToken = refreshTkn
        } else {
            refreshToken = "pleaseUpdateMe!"
        }
    }
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = "\(baseURLString)/auth/token"
        
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        
        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if
                    let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String
                {
                    do { try Locksmith.updateData(data: [
                        "accessToken": accessToken,
                        "refreshToken": refreshToken
                        ], forUserAccount: "spreadbotServerCreds")
                    } catch {}
                    completion(true, accessToken, refreshToken)
                } else {
                    completion(false, nil, nil)
                }
                
                strongSelf.isRefreshing = false
        }
    }
    
    // MARK: - Private - Reachability Manager
    
    private let reachabilityManager = ReachabilityManager()
    
    // An observable that completes when the app gets online (possibly completes immediately).
    private func connectedToInternet() -> Observable<Bool> {
        let online = reachabilityManager?.reach
        return online!
    }

}
