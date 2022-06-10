//
//  BithubPlugins.swift
//  Gilgamesh
//
//  Created by Linsz on 2018/6/27.
//  Copyright © 2018 Linsz. All rights reserved.
//

import Foundation
import Moya

/// A protocol for controlling the behavior of `AccessTokenPlugin`.
public protocol Signaturable {
    var signatureType: SignatureType { get }
    var signedParams: [String: Any]  { get }
    var requestParams: [String: Any] { get }
}

extension Signaturable where Self: TargetType {
    public var signedParams: [String: Any] {
        return requestParams
    }

    public var signatureType: SignatureType {
        return .identity
    }
}

// MARK: - SignatureType
public enum SignatureType {
    /// Api streaking
    case none

    /// Api should crypto
    case identity

    /// Api initial for login
    case initial
}

// MARK: - SignaturePlugin
/// A plugin for adding identity-signature headers to requests.
public final class SignaturePlugin: PluginType {

    public init() {}
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let signaturable = target as? Signaturable  else { return request }

        var request = request
        
        request.setValue("ios", forHTTPHeaderField: "client")

        switch signaturable.signatureType {
        case .initial: break
        case .identity:
//            let apiTimestamp = HttpParamEncodeTool.getTimestamp()
//            request.addValue(apiTimestamp, forHTTPHeaderField: "apiTimestamp")
//
//            let apiSignature = HttpParamEncodeTool.getapiSignature(withParams: signaturable.signedParams)
//            request.addValue(apiSignature, forHTTPHeaderField: "apiSignature")
            break
        case .none: break
        }
        return request
    }
}
