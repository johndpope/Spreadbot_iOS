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
    
    static let baseURLString = ProcessInfo.processInfo.environment["SPREADBOT_URL"] ?? "http://localhost:8080/raw"
    
    case getData(topic: String)
    case postData(topic: String, parameters: Parameters)
    
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
        let url = try AlamofireRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .getData(_):
            urlRequest = try URLEncoding.default.encode(urlRequest)
        case .postData(_, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest)
            urlRequest.httpBody = parameters
        default:
            break
        }
        return urlRequest
    }
    
}
