//
//  AlamofireNetworkDispatcher.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class AlamofireNetworkDispatcher: SpreadbotNetworkDispatcher {
    
    private let spreadbotAuthHandler = AlamofireAuthHandler()
    private let sessionManager = SessionManager()
    
    init() {
        sessionManager.adapter = spreadbotAuthHandler
        sessionManager.retrier = spreadbotAuthHandler
    }
    
    static func getData(path: String) -> Observable<AnyObject?> {
        return create { observer in
            let request = sessionManager.request(AlamofireRouter.getData(path))
                .validate(statusCode: 200..<300)
                .response(completionHandler: { request, response, data, error in
                    
                    if ((error) != nil) {
                        observer.on(.Error(error!))
                    } else {
                        observer.on(.Next(data))
                        observer.on(.Completed)
                    }
                    
                })
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    static func postData(path: String, payload: NSData) -> Observable<AnyObject?> {
        return create { observer in
            let request = sessionManager.request(AlamofireRouter.postData(path), parameters: payload)
                .validate(statusCode: 200..<300)
                .response(completionHandler: { request, response, data, error in
                    
                    if ((error) != nil) {
                        observer.on(.Error(error!))
                    } else {
                        observer.on(.Next(data))
                        observer.on(.Completed)
                    }
                    
                })
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
}
