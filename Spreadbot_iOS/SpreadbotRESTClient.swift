//
//  SpreadbotRESTClient.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import RxSwift

protocol SpreadbotNetworkDispatcher {
    
    static func getData(path: String) -> Observable<Any>
    
    static func postData(path: String, payload: NSData) -> Observable<Any>
    
}
