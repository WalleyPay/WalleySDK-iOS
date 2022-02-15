import UIKit
import WebKit

public protocol WalleyCheckoutViewDelegate: AnyObject {
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, didSendEvent event: WalleyCheckoutEvent)
    func walleyCheckoutView(_ walleyCheckoutView: WalleyCheckoutView, didUpdateHeight height: CGFloat)
}

public class WalleyCheckoutView: UIView {
    
    private let webView: WKWebView = .init()
    
    private let scriptMessageHandler: ScriptMessageHandler = .init()
    private let navigationDelegate: NavigationDelegate = .init()
    private let walleyCheckout: WalleyCheckout = .init()
    
    /// Credentials used when loading checkout view
    public var credentials: Credentials? {
        set {
            walleyCheckout.credentials = newValue
        }
        get {
            walleyCheckout.credentials
        }
    }
    
    /// Sends checkout events and view height updates
    public weak var delegate: WalleyCheckoutViewDelegate?

    /// Set this to a hexadecimal color code to change the background color of call to action buttons.
    ///
    /// Format as the following example: `#582f87`.
    ///
    /// Button text color will automatically be set to dark gray instead of white if not enough contrast according to WCAG 2.0 level AA for large text.
    public var actionColorHex: String?
    
    /// The display language.
    ///
    /// Currently supported combinations are: `sv-SE`, `en-SE`, `nb-NO`, `fi-FI`, `sv-FI`, `da-DK` and `en-DE`. Both `sv-SE` and `en-SE` are available for use with swedish partners.
    ///
    /// In the other cases, the country part must match the country code used when initializing the checkout session or it will be ignored.
    ///
    /// Setting this attribute is optional and will only be of interest when there is more than one language for any single country.
    public var language: String?
    
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
        webView.customUserAgent = Network.userAgent
        webView.scrollView.alwaysBounceVertical = false
        webView.navigationDelegate = navigationDelegate
        scriptMessageHandler.checkoutView = self
        navigationDelegate.checkoutView = self
    }
    
    public func loadCheckout(_ checkout: Checkout) {
        walleyCheckout.initCheckout(checkout) { (result: Result<InitCheckoutData, Error>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let stringToLoad = self.walleyCheckout.createCheckoutHTML(
                        publicToken: response.publicToken,
                        actionColorHex: self.actionColorHex,
                        language: self.language
                    )
                    self.webView.loadHTMLString(stringToLoad, baseURL: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
//        guard let checkoutView = checkoutView,
//        let checkout = checkoutView.checkout else {
//            decisionHandler(.cancel)
//            return
//        }
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
            } else if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
                let vc = WebViewController()
                vc.loadUrl(url)
                webView.parentViewController?.present(vc, animated: true)
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
