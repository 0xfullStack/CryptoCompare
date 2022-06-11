//
//  Endpoint.swift
//  
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Alamofire
import Moya

class DefaultAlamofireSession: Alamofire.Session {
    static let sharedSession: DefaultAlamofireSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        configuration.timeoutIntervalForRequest = 20   // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireSession(configuration: configuration)
    }()
}

let provider = MoyaProvider<Endpoint>(
    session: DefaultAlamofireSession.sharedSession,
    plugins: [NetworkLoggerPlugin(), SignaturePlugin()]
)

public enum Endpoint {
    case market(fsyms: [String], tsyms: [String])
}

extension Endpoint: TargetType{
    public var baseURL: URL {
        return URL(string: "https://min-api.cryptocompare.com")!
    }
    public var path: String {
        switch self {
        case .market(_, _): return "/data/pricemultifull"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .market(_, _): return .get
        }
    }

    public var task: Task {
        switch self {
        case .market(_, _):
            return .requestParameters(parameters: signedParams, encoding: URLEncoding.default)
        }
    }
    
    public var sampleData: Data { return Data() }
    public var headers: [String: String]? { return nil }
}

extension Endpoint {
    public var requestParams: [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .market(let fsyms, let tsyms):
            params["fsyms"] = fsyms.joined(separator: ",")
            params["tsyms"] = tsyms.joined(separator: ",")
            return params
        }
    }
}

extension Endpoint: Signaturable {}
