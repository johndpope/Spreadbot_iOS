//
//  AlamofireRouter.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import Alamofire

enum AlamofireRouter: URLRequestConvertible {
        
    case getData(topic: String)
    case postData(topic: String, payload: NSData)
    
    var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        case .postData:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getData(let topic):
            return "/\(topic)"
        case .postData(let topic, _):
            return "/\(topic)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = try SpreadbotConfig.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .postData(_, let payload):
            urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = payload as Data
        default:
            break
        }
        
        return urlRequest
    }
    
}
