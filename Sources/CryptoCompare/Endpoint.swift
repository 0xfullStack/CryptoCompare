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

public func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}


let endpoint = MoyaProvider<CryptoCompare>(
    session: DefaultAlamofireSession.sharedSession,
    plugins: [
        NetworkLoggerPlugin(),
        SignaturePlugin()
    ]
)

public enum CryptoCompare {
    case ticker(String)
}

extension CryptoCompare: TargetType{
    public var baseURL: URL {
        return URL(string: "")!
    }
    public var path: String {
        switch self {
        case .ticker: return "/market/data/ticker"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .ticker: return .get
        }
    }


    public var task: Task {
        switch self {
        case .ticker:
            return .requestParameters(parameters: signedParams, encoding: URLEncoding.default)
        }
    }
}

extension CryptoCompare: Signaturable {
    public var requestParams: [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .ticker(let symbol):
            params["symbol"] = symbol
            params["version"] = "v1.0.0"
            return params
        }
    }
}
