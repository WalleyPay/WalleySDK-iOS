import UIKit
import WebKit

public class WalleyCheckoutController: UIViewController {
    
    private var walleyCheckoutView: WalleyCheckoutView = .init()
    
    /// Credentials used when loading checkout view
    public var credentials: Credentials? {
        set {
            walleyCheckoutView.credentials = newValue
        }
        get {
            walleyCheckoutView.credentials
        }
    }
    
    /// Sends checkout events and view height updates
    public weak var delegate: WalleyCheckoutViewDelegate? {
        set {
            walleyCheckoutView.delegate = newValue
        }
        get {
            walleyCheckoutView.delegate
        }
    }
    
    /// Set this to a hexadecimal color code to change the background color of call to action buttons.
    ///
    /// Format as the following example: `#582f87`.
    ///
    /// Button text color will automatically be set to dark gray instead of white if not enough contrast according to WCAG 2.0 level AA for large text.
    public var actionColorHex: String? {
        set {
            walleyCheckoutView.actionColorHex = newValue
        }
        get {
            walleyCheckoutView.actionColorHex
        }
    }
    
    /// The display language.
    ///
    /// Currently supported combinations are: `sv-SE`, `en-SE`, `nb-NO`, `fi-FI`, `sv-FI`, `da-DK` and `en-DE`. Both `sv-SE` and `en-SE` are available for use with swedish partners.
    ///
    /// In the other cases, the country part must match the country code used when initializing the checkout session or it will be ignored.
    ///
    /// Setting this attribute is optional and will only be of interest when there is more than one language for any single country.
    public var language: String? {
        set {
            walleyCheckoutView.language = newValue
        }
        get {
            walleyCheckoutView.language
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
    
    public func loadCheckout(_ checkout: Checkout) {
        walleyCheckoutView.loadCheckout(checkout)
    }

}

