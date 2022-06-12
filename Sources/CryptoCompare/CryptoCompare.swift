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

    private lazy var webSocket: WebSocket = {
        var request = URLRequest(url: URL(string: socketURL)!)
        request.timeoutInterval = 5
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        return WebSocket(request: request, compressionHandler: WSCompression())
    }()

    private init() {
        webSocket.connect()
    }
    
    public var connectStatus: Observable<Bool> {
        return webSocket.rx.connected.share()
    }
    
    public static let shared = CryptoCompare()
}

extension CryptoCompare {

    public func fetch(_ target: Endpoint) -> Observable<[String: [String: Market]]> {
        return provider.rx
            .request(target)
            .asObservable()
            .mapObject([String: [String: Market]].self, atKeyPath: "RAW", context: Datasource.cryptoCompare)
    }
}

extension CryptoCompare {
    
    public func on(_ event: Event) -> Observable<Data> {
        connectStatus
            .filter { $0 }
            .flatMapLatest { [weak self] connected -> Observable<Void> in
                guard let self = self else { return .never() }
                let data = try event.encode(action: .add)
                return self.webSocket.rx.write(data: data)
            }
            .observe(on: MainScheduler.asyncInstance)
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self = self else { return .never() }
                return self.webSocket.rx.text
            }
            .flatMapLatest { [weak self] text -> Observable<Data> in
                guard let self = self else { return .never() }
                return self.filterCorrespondType(text: text, event: event)
            }
    }
    
    public func off(_ event: Event) -> Observable<Void> {
        fatalError("Not implemented!!")
    }
    
    private func filterCorrespondType(text: String, event: Event) -> Observable<Data> {
        do {
            let data = Data(text.utf8)
            let messageType = try JSONDecoder().decode(EventFilter.self, from: data).type
            return messageType == event.messageType ? .just(data) : .never()
        } catch {
            return .never()
        }
    }
}
