import XCTest
import RxSwift
@testable import CryptoCompare

final class CryptoCompareTests: XCTestCase {
    
    private let bag = DisposeBag()
    
    func testFetchingMarket() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(CryptoCompare().text, "Hello, World!")
        
        
        let expectation = XCTestExpectation(description: "Fetching Market info failure")
        
        CryptoCompare()
            .fetch(.market(fsyms: ["BTC", "ETH"], tsyms: ["USD"]))
            .subscribe { market in
                print(market)
                expectation.fulfill()
            } onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: TimeInterval(5))
    }
}
