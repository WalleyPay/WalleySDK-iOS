import XCTest
@testable import WalleyCheckout

final class WalleyCheckoutTests: XCTestCase {
    
    func testDefaultEnvironmentIsProduction() throws {
        XCTAssertEqual(WalleyCheckout.environment, .production)
    }
    
}
