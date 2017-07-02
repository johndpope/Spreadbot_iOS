//
//  SpreadbotWebSocketClient.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import SocketIO

class SpreadbotWebSocketClient {
    
    static let sharedInstance = SpreadbotWebSocketClient()
    
    private let online: Observable<Bool>
    private var baseURLString: String
    
    var socket = reachableSocket()
    
    override init(online: Observable<Bool> = connectedToInternetOrStubbing()) {
        self.baseURLString = baseURLString()
        super.init()
    }
    
    static func establishConnection() {
        socket.connect()
    }
    
    static func closeConnection() {
        socket.disconnect()
    }
    
    static func subscribe(path: String, completionHandler: (NSData) -> Void) {
        socket.joinNamespace(path)
        socket.onAny { ( data, ack) -> Void in
            completionHandler(data as? NSData)
        }
    }
    
    static func sendMessage(eventData: NSData) {
        do {
            socket.emit(topicToSubscribeTo, eventData)
        } catch let error as SocketClientEvent.error {
            print("Error with sendMessage: \(error)")
        }
    }
    
    // MARK: - Private - Reachability Manager
    
    private let reachabilityManager = ReachabilityManager()
    private let isStubing = false
    
    // An observable that completes when the app gets online (possibly completes immediately).
    private func connectedToInternetOrStubbing() -> Observable<Bool> {
        let stubbing = Observable.just(isStubing)
        
        guard let online = reachabilityManager?.reach else {
            return stubbing
        }
        
        return [online, stubbing].combineLatestOr()
    }
    
    // MARK: - Private - Helper Functions
    
    private func reachableSocket() {
        let urlString = "\(baseURLString)/wss/"
        
        var socketReq = SocketIOClient(socketURL: URL(string: "\(urlString)")!, config: [
            forceNew: false, log: false, reconnects: true, reconnectAttempts: -1, reconnectWait: 3
            ])
        
        return reachableSocket = online
            .ignore(false)        // Wait until we're online
            .take(1)              // Take 1
            .flatMap { _ in       // Turn the online state into a WebSocket
                return socketReq
        }
    }
    
    private func baseURLString() {
        if let baseURL = ProcessInfo.processInfo.environment["SPREADBOT_URL"] {
            return baseURL
        } else {
            return "http://localhost:8080"
        }
    }
    
    deinit {
        socket.disconnect()
    }
    
}
