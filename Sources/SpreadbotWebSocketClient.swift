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

    private var socket: SocketIOClient

    override init() {
        self.socket = SocketIOClient(socketURL: URL(string: "\(SpreadbotConfig.baseURLString)/wss/")!, config: [.forceNew(false), .log(false), .reconnects(true), .reconnectAttempts(-1), .reconnectWait(3)])
    }
    
    public func establishConnection() {
        socket.connect()
    }
    
    public func closeConnection() {
        socket.disconnect()
    }
    
    public func subscribe(path: String, completionHandler: @escaping (Any) -> Void) {
        socket.joinNamespace(path)
        socket.onAny {
            print("Got event: \($0.event), with items: \(String(describing: $0.items))")
            completionHandler($0.items as Any)
        }
    }
    
    public func sendMessage(path: String, message: NSData) {
        socket.emit(path, message)
        print("Message sent. Path: \(path)")
    }
    
    deinit {
        socket.disconnect()
    }
    
}
