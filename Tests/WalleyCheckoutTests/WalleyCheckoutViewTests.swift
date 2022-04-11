import XCTest
@testable import WalleyCheckout

final class WalleyCheckoutViewTests: XCTestCase {
    
    func testCustomScriptMessageHandlerRecievesMessage() throws {
        // GIVEN
        let view = WalleyCheckoutView()
        let name = "testNotifications"
        let body = "testMessage"
        let expectation = XCTestExpectation(description: "Wait for message handler")
        let messageHandler = ScriptMessageHandlerMock { message in
            XCTAssert(message.name == name)
            XCTAssert(message.body as! String == body)
            expectation.fulfill()
        }
        
        // WHEN
        view.registerScriptMessageHandler(messageHandler, name: name)
        view.webView.loadHTMLString("""
        <body>
        <script type="text/javascript">
            window.webkit.messageHandlers.\(name).postMessage('\(body)')
        </script>
        </body>
        """, baseURL: nil)
        
        // THEN
        if XCTWaiter.wait(for: [expectation], timeout: 5) == .timedOut {
            XCTFail("Message never sent")
        }
    }
    
}
