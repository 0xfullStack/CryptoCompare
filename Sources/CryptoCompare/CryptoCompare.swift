//
//  CryptoCompareClient.swift
//
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Starscream
import RxSwift
import RxMoya
import Infura

public final class CryptoCompare {

    private let url = "https://min-api.cryptocompare.com/data"
    private let socketURL = "wss://streamer.cryptocompare.com/v2"
    private let apiKey = "Apikey f3672c3f30bf06d32f91858ab64fd384d6bb025d2d03e9f9dddb0e2196223620"

    @Published private(set) public var connectionStatus: ConnectionStatus = .disConnected
    private var connectionStatusCallback: ((ConnectionStatus)->Void)? = nil
    private var subscriptionsCallback: [(CryptoCompareEvent, (Result<Data, Web3Error>)->())] = []

    private lazy var webSocket: WebSocket = {
        var request = URLRequest(url: URL(string: socketURL)!)
        request.timeoutInterval = 5
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        return WebSocket(request: request, compressionHandler: WSCompression())
    }()

    public init() {
//        webSocket.delegate = self
    }
}

extension CryptoCompare {

    public func fetch(_ target: Endpoint) -> Observable<[String: [String: Market]]> {
        return provider.rx
            .request(target)
            .asObservable()
            .mapObject([String: [String: Market]].self, atKeyPath: "RAW", context: Datasource.cryptoCompare)
    }

//    private func send(event: CryptoCompareEvent) throws {
//        guard connectionStatus == .connected else {
//            return
//        }
//        let data = try event.encode(action: .add)
//        webSocket.write(data: data)
//    }
//
//    public func on(_ event: CryptoCompareEvent, callback: @escaping (Result<Data, Web3Error>)->()) {
//
//        if connectionStatus != .connected {
//            connectionStatusCallback = { [weak self] connectionStatus in
//                guard let self = self else { return }
//
//                switch connectionStatus {
//                case .connected:
//                    do {
//                        try self.send(event: event)
//                    } catch {
//                        callback(.failure(.invalidSubscribeEvent(event.description + " " + error.localizedDescription)))
//                    }
//                case .error(let error):
//                    callback(.failure(.socketDidNotConnect(error)))
//                case.disConnected:
//                    callback(.failure(.socketDidNotConnect(nil)))
//                }
//            }
//            webSocket.connect()
//        } else {
//            do {
//                try send(event: event)
//            } catch {
//                callback(.failure(.invalidSubscribeEvent(event.description + " " + error.localizedDescription)))
//            }
//        }
//        subscriptionsCallback.append((event, callback))
//    }
}

//extension CryptoCompare: WebSocketDelegate {
//
//    public func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(_):
//            connectionStatus = .connected
//            connectionStatusCallback?(connectionStatus)
//        case .disconnected(_, _):
//            connectionStatus = .disConnected
//            connectionStatusCallback?(connectionStatus)
//        case .text(let text):
//            mapFilter(data: Data(text.utf8))
//        case .error(let error):
//            connectionStatus = .error(Web3Error.socketDidNotConnect(error))
//            connectionStatusCallback?(connectionStatus)
//        default: break
//        }
//    }
//
//    private func mapFilter(data: Data) {
//        struct Filter: Decodable {
//            let type: CryptoCompare.MessageType
//
//            enum CodingKeys: String, CodingKey {
//                case type = "TYPE"
//            }
//        }
//
//        guard let filter = try? JSONDecoder().decode(Filter.self, from: data) else {
//            return
//        }
//        guard let sub = subscriptionsCallback.filter({ $0.0.messageType == filter.type }).first else {
//            return
//        }
//
//        sub.1(.success(data))
//    }
//}
