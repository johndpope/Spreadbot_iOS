//
//  SpreadbotRESTClient.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

class SpreadbotRESTClient {
    
    private let dispatcher: SpreadbotNetworkDispatcher
    private let backgroundWorkScheduler: ImmediateSchedulerType
    private let mainScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()
    
    init(dispatcher: SpreadbotNetworkDispatcher) {
        self.dispatcher = dispatcher
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        #if !RX_NO_MODULE
            operationQueue.qualityOfService = QualityOfService.userInitiated
        #endif
        
        self.backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        self.mainScheduler = MainScheduler.instance
    }
    
    func getData(path: String, onSuccess: @escaping (Any) -> Void, onError: @escaping (NSError) -> Void) {
        let online = connectedToInternet()
        dispatcher.getData(path: path)
            // Pause if no internet connection
            .pausableBuffered(online, limit: 3)
            // Set 3 attempts to get response
            .retry(.exponentialDelayed(maxCount: 3, initial: 2.0, multiplier: 1.5), scheduler: backgroundWorkScheduler as! SchedulerType)
            // Set 2 seconds timeout
            .timeout(2, scheduler: backgroundWorkScheduler as! SchedulerType)
            // Subscribe in background thread
            .subscribeOn(backgroundWorkScheduler)
            // Observe in main thread
            .observeOn(mainScheduler)
            // Subscribe on observer
            .subscribe(
                onNext: { data in
                    onSuccess(data!)
                },
                onError: { error in
                    onError(error)
                } as? ((Error) -> Void),
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {
                    print("Disposed")
                }
            )
        .addDisposableTo(disposeBag)
    }

    func postData(path: String, payload: NSData, onSuccess: @escaping (Any) -> Void, onError: @escaping (NSError) -> Void) {
        let online = connectedToInternet()
        dispatcher.postData(path: path, payload: payload)
            // Pause if no internet connection
            .pausableBuffered(online, limit: 3)
            // Set 3 attempts to get response
            .retry(.exponentialDelayed(maxCount: 3, initial: 2.0, multiplier: 1.5), scheduler: backgroundWorkScheduler as! SchedulerType)
            // Set 2 seconds timeout
            .timeout(2, scheduler: backgroundWorkScheduler as! SchedulerType)
            // Subscribe in background thread
            .subscribeOn(backgroundWorkScheduler)
            // Observe in main thread
            .observeOn(mainScheduler)
            // Subscribe on observer
            .subscribe(
                onNext: { data in
                    onSuccess(data!)
                },
                onError: { error in
                    onError(error)
                } as? ((Error) -> Void),
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {
                    print("Disposed")
                }
            )
        .addDisposableTo(disposeBag)
    }

    // MARK: - Private - Reachability Manager

    private let reachabilityManager = ReachabilityManager()
    
    // An observable that completes when the app gets online (possibly completes immediately).
    private func connectedToInternet() -> Observable<Bool> {
        let online = reachabilityManager?.reach
        return online!
    }

}
