//
//  AlamofireAuthHandler.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import RxSwift
import Locksmith

class AlamofireAuthHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private let online: Observable<Bool>
    private let spreadbotServerCredsDictionary = Locksmith.loadDataForUserAccount("spreadbotServerCreds")
    
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    public init(online: Observable<Bool> = connectedToInternetOrStubbing()) {
        self.baseURLString = baseURLString()
        self.accessToken = accessToken()
        self.refreshToken = refreshToken()
        self.online = online
    }
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        return online
            .ignore(false)      // Wait until we're online
            .take(1)            // Take 1 to make sure we only invoke the API once.
            .flatMap { _ in     // Turn the online state into a network request
                return urlRequest
        }
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
                        try Locksmith.updateData([
                            "accessToken": accessToken,
                            "refreshToken": refreshToken
                            ], forUserAccount: "spreadbotServerCreds"
                        )
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
    private func connectedToInternetOrStubbing() -> Observable<Bool> {
        let stubbing = Observable.just(ProcessInfo.processInfo.environment["IS_STUBBING"] ?? false)
        
        guard let online = reachabilityManager?.reach else {
            return stubbing
        }
        
        return [online, stubbing].combineLatestOr()
    }
    
    // MARK: - Private - Helper Functions
    
    private func baseURLString() {
        if let baseURL = ProcessInfo.processInfo.environment["SPREADBOT_AUTH_URL"] {
            return baseURL
        } else {
            return "http://localhost:8080/raw"   
        }
    }
    
    private func accessToken() {
        if let authTkn = spreadbotServerCredsDictionary["accessToken"] as? String {
            return authTkn
        } else {
            return "pleaseUpdateMe!" 
        }
    }
    
    private func refreshToken() {
        if let refreshTkn = spreadbotServerCredsDictionary["refreshToken"] as? String {
            return refreshTkn
        } else {
            return "pleaseUpdateMe!"
        }
    }
    
}
