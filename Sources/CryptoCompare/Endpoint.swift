//
//  Endpoint.swift
//  
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Alamofire
import Moya

public extension TargetType {
    var sampleData: Data { return Data() }
    var headers: [String: String]? { return nil }
}

public class DefaultAlamofireSession: Alamofire.Session {
    static let sharedSession: DefaultAlamofireSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        configuration.timeoutIntervalForRequest = 20   // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireSession(configuration: configuration)
    }()
}

let endpoint = MoyaProvider<CryptoCompare>(
    session: DefaultAlamofireSession.sharedSession,
    plugins: [
        NetworkLoggerPlugin(),
        SignaturePlugin()
    ]
)

public enum CryptoCompare {
    case market(fsyms: [String], tsyms: [String])
}

extension CryptoCompare: TargetType{
    public var baseURL: URL {
        return URL(string: "https://min-api.cryptocompare.com/data")!
    }
    public var path: String {
        switch self {
        case .market(_, _): return "/pricemultifull"
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
}

extension CryptoCompare: Signaturable {
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
