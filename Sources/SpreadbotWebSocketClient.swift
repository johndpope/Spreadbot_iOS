//
//  SpreadbotWebSocketClient.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import SocketIO

public class SpreadbotWebSocketClient: NSObject {

    static let sharedInstance = SpreadbotWebSocketClient()
    
    static let baseURLString = { () -> String in
        if let baseURL = ProcessInfo.processInfo.environment["SPREADBOT_URL"] {
            return baseURL
        } else {
            return "http://localhost:8080"
        }
    }

    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "\(baseURLString)/wss/")!, config: [.forceNew(false), .log(false), .reconnects(true), .reconnectAttempts(-1), .reconnectWait(3)])
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func subscribe(path: String, completionHandler: @escaping (Any) -> Void) {
        socket.joinNamespace(path)
        socket.onAny {
            print("Got event: \($0.event), with items: \(String(describing: $0.items))")
            completionHandler($0.items as Any)
        }
    }
    
    func sendMessage(path: String, eventData: NSData, completionHandler: @escaping () -> Void) {
        socket.emit(path, eventData)
        completionHandler()
    }
    
    deinit {
        socket.disconnect()
    }
    
}
