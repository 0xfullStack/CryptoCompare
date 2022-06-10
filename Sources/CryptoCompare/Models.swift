//
//  Models.swift
//  
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import ObjectMapper

public enum MessageType: String, Codable {
    // Channels
    // https://min-api.cryptocompare.com/documentation/websockets?key=Channels&cat=OrderbookL2&api_key=f3672c3f30bf06d32f91858ab64fd384d6bb025d2d03e9f9dddb0e2196223620
    case trade = "0"
    case ticker = "2"
    case aggregateIndexCCCAGG = "5" //
    case OHLCCandles = "24"
    case fullVolume = "11"
    case topTierFullVolume = "21"
    case orderBookUpdate = "8"
    case orderBookSnapshot = "9"
    case topOfOrderBook = "30"

    // Socket connection
    case streamerWelcome = "20"
    case heartBeat = "999"
}

enum MessageAction: String, Codable {
    case add = "SubAdd"
    case remove = "SubRemove"
}

public struct Market: Mappable {
    public var raw: [String: [String: Detail]]
    
    public init?(map: Map) {
        do {
            raw = try map.value("RAW")
        } catch {
            return nil
        }
    }
    
    mutating public func mapping(map: Map) {
        raw <- map["RAW"]
    }
}

public struct Detail: Codable {
    public let type: MessageType
    public let price: Float64?
    public let volume24Hour: Float64
    public let volumeDay: Float64

    public let circulatingSupply: Float64?
    public let circulatingSupplyMarketCap: Float64?

    public let open24Hour: Float64?
    public let high24Hour: Float64?
    public let low24Hour: Float64?
    
    public let from: String
    public let to: String

    public var changePercent24Hour: Float64? {
        if let price = price, let open24Hour = open24Hour {
            return (price-open24Hour)*100/open24Hour
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case type = "TYPE"
        case price = "PRICE"
        case volume24Hour = "VOLUME24HOUR"
        case volumeDay = "VOLUMEDAY"
        case circulatingSupply = "CIRCULATINGSUPPLY"
        case circulatingSupplyMarketCap = "CIRCULATINGSUPPLYMKTCAP"

        case open24Hour = "OPEN24HOUR"
        case high24Hour = "HIGH24HOUR"
        case low24Hour = "LOW24HOUR"
        
        case from = "FROMSYMBOL"
        case to = "TOSYMBOL"
    }
}

public enum ConnectionStatus: Equatable {
    case connected
    case disConnected
    case error(Web3Error?)

    public static func ==(lfs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lfs, rhs) {
        case (.connected, .connected), (.disConnected, .disConnected), (.error(_), .error(_)):
            return true
        default:
            return false
        }
    }

    public static func !=(lfs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lfs, rhs) {
        case (.connected, .connected), (.disConnected, .disConnected), (.error(_), .error(_)):
            return false
        default:
            return true
        }
    }
}

public enum Web3Error: Error, LocalizedError {
    case signingError
    case socketDidNotConnect(Error?)
    case socketConnectError(String?)
    case invalidRequest
    case invalidSubscribeEvent(String)
    case wrongJsonFromat(Error?)
    case decodeError(Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .socketConnectError(let description):
            return description
        case .signingError:
            return "Singing error"
        case .socketDidNotConnect(let error):
            return "Socket did not connect: \(String(describing: error?.localizedDescription))"
        case .invalidRequest:
            return "Invalid request"
        case .wrongJsonFromat(let error):
            return "Attempt to decode invalid json string, \(String(describing: error?.localizedDescription)) "
        case .invalidSubscribeEvent(let description):
            return "Invalid subscribe event: \(description)"
        case .decodeError(let error):
            return "Decode faiulre: \(error.localizedDescription)"
        case .unknown:
            return "Unknow error"
        }
    }
}

public enum CryptoCompareEvent {
    case marketInfo(syms: [(String, String)])

    func encode(action: MessageAction) throws -> Data {
        switch self {
        case .marketInfo(let syms):
            let subs = syms.map { "\(messageType.rawValue)~\(Market.cccagg.rawValue)~\($0.0)~\($0.1)" }
            let topic = Topic(action: action.rawValue, subs: subs)
            return try JSONEncoder().encode(topic)
        }
    }

    private struct Topic: Codable {
        let action: String
        let subs: [String]
    }

    private enum Market: String {
        case cccagg = "CCCAGG" // CryptoCompare Aggregate
        case coinbase = "Coinbase"
        case binance = "Binance"
    }

    var messageType: MessageType {
        switch self {
        case .marketInfo(_):
            return .aggregateIndexCCCAGG
        }
    }

    var description: String {
        switch self {
        case .marketInfo(let syms):
            return "\(CryptoCompare.self): \(syms)"
        }
    }
}
