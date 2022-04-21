import UIKit
import WebKit

public protocol WalleyCheckoutDelegate: AnyObject {
    
    /// Recieve WalleyCheckout events
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, didSendEvent event: WalleyCheckoutEvent)
    
    /// Called when WalleyCheckout view has updated height. The view has updated its intrinsic content size.
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, didUpdateHeight height: CGFloat)
    
    /// Called when user taps on a link inside WalleyCheckout UI.
    ///
    /// - Returns: Return true if WalleyCheckout should use default web view presentation.
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, shouldOpenUrl url: URL) -> Bool
}

extension WalleyCheckoutDelegate {
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, shouldOpenUrl url: URL) -> Bool {
        return true
    }
}

final public class WalleyCheckoutView: UIView {
    
    internal let webView: WKWebView = .init()
    
    private let scriptMessageHandler: ScriptMessageHandler = .init()
    private let navigationDelegate: NavigationDelegate = .init()
    private let walleyCheckout: WalleyCheckout = .init()
    
    /// Sends checkout events and view height updates
    public weak var delegate: WalleyCheckoutDelegate?
    
    fileprivate var webViewHeight: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.invalidateIntrinsicContentSize()
                self.delegate?.walleyCheckoutView(self, didUpdateHeight: self.webViewHeight)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leftAnchor.constraint(equalTo: leftAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        setupWalleyEvents()
        setupHeightUpdateEvent()
        webView.customUserAgent = "WalleyPaySDK/1.0 iOS/\(UIDevice.current.systemVersion)/\(UIDevice.current.model ?? "")"
        webView.scrollView.alwaysBounceVertical = false
        webView.navigationDelegate = navigationDelegate
        scriptMessageHandler.checkoutView = self
        navigationDelegate.checkoutView = self
    }
    
    /// Loads checkout view using public token
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    public func loadCheckout(publicToken: String, actionColor: String? = nil, language: String? = nil) {
        let stringToLoad = self.walleyCheckout.createCheckoutHTML(
            publicToken: publicToken,
            actionColor: actionColor,
            language: language
        )
        self.webView.loadHTMLString(stringToLoad, baseURL: nil)
    }
    
    /// Register a custom script message handler to recieve script messages from a custom page for when a purchase is completed
    ///
    /// - Parameters:
    ///   - handler: The script message handler to register
    ///   - name: The name of the message handler.
    public func registerScriptMessageHandler(_ handler: WKScriptMessageHandler, name: String) {
        webView.configuration.userContentController.add(handler, name: name)
    }
    
    private func setupWalleyEvents() {
        let listenerName = "iosListener"
        for event in WalleyCheckoutEvent.allCases {
            setupEvent(
                name: event.rawValue,
                listener: listenerName
            )
        }
        webView.configuration.userContentController.add(scriptMessageHandler, name: listenerName)
    }
    
    private func setupEvent(name: String, listener: String) {
        let source = """
            document.addEventListener("\(name)", function() {
                window.webkit.messageHandlers.\(listener).postMessage({event: "\(name)"});
            })
        """
        let script = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func setupHeightUpdateEvent() {
        let scriptSource = """
            const element = document.querySelector('.collector-checkout-iframe')
            const resizeObserver = new ResizeObserver(entries => {
                const entry = entries[0]
                window.webkit.messageHandlers.sizeNotification.postMessage({height: entry.contentRect.height})
            })
            resizeObserver.observe(element)
        """
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(scriptMessageHandler, name: "sizeNotification")
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: webViewHeight)
    }
    
}

class NavigationDelegate: NSObject, WKNavigationDelegate {
    
    weak var checkoutView: WalleyCheckoutView?
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.hasPrefix("bankid://"), let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    showMessage(title: "BankID app not installed")
                }
            } else if urlString.hasPrefix("swish://"), let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    showMessage(title: "Swish app not installed")
                }
            } else if let url = navigationAction.request.url,
                      navigationAction.navigationType == .linkActivated,
                      let checkoutView = checkoutView,
                      checkoutView.delegate?.walleyCheckoutView(checkoutView, shouldOpenUrl: url) == true {
                let vc = WebViewController()
                vc.loadUrl(url)
                let nc = UINavigationController(rootViewController: vc)
                checkoutView.parentViewController?.present(nc, animated: true)
            }
        }
        decisionHandler(.allow)
    }
    
    private func showMessage(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        checkoutView?.parentViewController?.present(alertController, animated: true)
    }
    
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var checkoutView: WalleyCheckoutView?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let checkoutView = checkoutView else { return }
        guard let dict = message.body as? [String : Any] else { return }
        if let eventString = dict["event"] as? String, let event = WalleyCheckoutEvent(rawValue: eventString) {
            checkoutView.delegate?.walleyCheckoutView(checkoutView, didSendEvent: event)
        }
        if let height = dict["height"] as? CGFloat {
            checkoutView.webViewHeight = height
        }
    }
    
}
