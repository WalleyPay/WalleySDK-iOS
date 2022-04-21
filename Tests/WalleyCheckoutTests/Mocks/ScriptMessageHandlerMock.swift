import WebKit

class ScriptMessageHandlerMock: NSObject, WKScriptMessageHandler {
    
    let action: (WKScriptMessage) -> ()
    
    init(action: @escaping (WKScriptMessage) -> ()) {
        self.action = action
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        action(message)
    }
    
}
