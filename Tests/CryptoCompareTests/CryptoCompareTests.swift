import XCTest
import RxSwift
@testable import CryptoCompare

final class CryptoCompareTests: XCTestCase {
    
    private let bag = DisposeBag()
    private let cryptoCompare = CryptoCompare()
    
    func testFetchingMarket() throws {
        
        let expectation = XCTestExpectation(description: "Fetching Market info failure")
        
        cryptoCompare
            .fetch(.market(fsyms: ["BTC", "ETH"], tsyms: ["USD"]))
            .subscribe { market in
                print(market)
                expectation.fulfill()
            } onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: TimeInterval(50))
    }
    
    func testSubscribeMarket() throws {
        
        let expectation = XCTestExpectation(description: "Subscribe Market info failure")
        
//        cryptoCompare
        
        wait(for: [expectation], timeout: TimeInterval(50))
    }
}

