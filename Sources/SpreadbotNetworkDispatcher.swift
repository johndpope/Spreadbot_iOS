//
//  SpreadbotNetworkDispatcher.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

protocol SpreadbotNetworkDispatcher {
    
    func getData(path: String) -> Observable<Any?>
    
    func postData(path: String, payload: NSData) -> Observable<Any?>
    
}
