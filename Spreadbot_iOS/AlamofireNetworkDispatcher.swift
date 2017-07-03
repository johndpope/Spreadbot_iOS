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
import RxSwiftExt

class AlamofireNetworkDispatcher: SpreadbotNetworkDispatcher {
    
    private let spreadbotAuthHandler = AlamofireAuthHandler()
    private let sessionManager = SessionManager()
    
    init() {
        sessionManager.adapter = spreadbotAuthHandler
        sessionManager.retrier = spreadbotAuthHandler
    }
    
    func getData(path: String) -> Observable<Any?> {
        return Observable.create { observer in
            self.sessionManager.request(AlamofireRouter.getData(topic: path))
                .validate(statusCode: 200..<300)
                .responseData(completionHandler: { response in
                    switch response.result {
                    case .success:
                        observer.on(.next(response.result.value))
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error))
                    }
                    
                })
            return Disposables.create()
        }
    }
    
    func postData(path: String, payload: NSData) -> Observable<Any?> {
        return Observable.create { observer in
            self.sessionManager.request(AlamofireRouter.postData(topic: path, payload: payload))
                .responseData(completionHandler: { response in
                    switch response.result {
                    case .success:
                        observer.on(.next(response.result.value))
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error))
                    }
                    
                })
            return Disposables.create()
        }
    }
}
