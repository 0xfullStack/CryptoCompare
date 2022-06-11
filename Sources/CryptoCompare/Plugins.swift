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
        return .identity(token: "Apikey f3672c3f30bf06d32f91858ab64fd384d6bb025d2d03e9f9dddb0e2196223620")
    }
}

// MARK: - SignatureType
public enum SignatureType {
    /// Api streaking
    case none

    /// Api should crypto
    case identity(token: String)

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

        switch signaturable.signatureType {
        case .initial: break
        case .identity(let token):
            request.setValue(token, forHTTPHeaderField: "authorization")
        case .none: break
        }
        return request
    }
}
