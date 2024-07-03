import UIKit
import WebKit

final public class WalleyCheckoutController: UIViewController {
    
    private var walleyCheckoutView: WalleyCheckoutView = .init()
    
    /// Delegate that handles WalleyCheckout events
    public weak var delegate: WalleyCheckoutDelegate? {
        set {
            walleyCheckoutView.delegate = newValue
        }
        get {
            walleyCheckoutView.delegate
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        walleyCheckoutView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(walleyCheckoutView)
        NSLayoutConstraint.activate([
            walleyCheckoutView.topAnchor.constraint(equalTo: view.topAnchor),
            walleyCheckoutView.leftAnchor.constraint(equalTo: view.leftAnchor),
            walleyCheckoutView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            walleyCheckoutView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// Loads checkout view using public token
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    ///    - actionTextColor: Override the automatic text color of call to action buttons. Valid values are black, white, #000000 and #ffffff.
    ///    - padding: Padding inside the iFrame, set to none to cancel left and right padding.
    ///    - containerId: ContainerID for where to render checkout iFrame inside of.
    public func loadCheckout(publicToken: String, actionColor: String? = nil, language: String? = nil, actionTextColor: String? = nil, padding: String? = nil, containerId: String? = nil) {
        walleyCheckoutView.loadCheckout(publicToken: publicToken, actionColor: actionColor, language: language, actionTextColor: actionTextColor, padding: padding, containerId: containerId)
    }
    
    /// Register a custom script message handler to recieve script messages from a custom page for when a purchase is completed
    ///
    /// - Parameters:
    ///   - handler: The script message handler to register
    ///   - name: The name of the message handler.
    public func registerScriptMessageHandler(_ handler: WKScriptMessageHandler, name: String) {
        walleyCheckoutView.registerScriptMessageHandler(handler, name: name)
    }

}

