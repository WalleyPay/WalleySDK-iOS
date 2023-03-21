import Foundation

final public class WalleyCheckout {
    
    public enum Environment {
        case production
        case test
        case ci
    }
    
    private var frontendHost: String {
        switch Self.environment {
        case .production: return "https://checkout.collector.se"
        case .test: return "https://checkout-uat.collector.se"
        case .ci: return "https://checkout-ci.collector.se/test.html"
        }
    }
    
    public static var environment: Environment = .production
    
    /// Generate walley checkout script tag using public token.
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    public func createCheckoutSnippet(publicToken: String, actionColorHex: String? = nil, language: String? = nil) -> String {
        """
        <script
          src="\(frontendHost)/collector-checkout-loader.js"
          data-token="\(publicToken)"
          data-webview="true"
          \(actionColorHex.map { "data-action-color=\"\($0)\"\n" } ?? "" )
          \(language.map { "data-lang=\"\($0)\"\n" } ?? "" )
        ></script>
        """
    }
    
    /// Generate html containing walley checkout script tag using public token.
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    public func createCheckoutHTML(publicToken: String, actionColor: String? = nil, language: String? = nil) -> String {
        """
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style='margin:0'>
          \(createCheckoutSnippet(publicToken: publicToken, actionColorHex: actionColor, language: language))
        </body>
        """
    }
    
}

public enum WalleyCheckoutEvent: String, CaseIterable {
    case customerUpdated = "walleyCheckoutCustomerUpdated"
    case locked = "walleyCheckoutLocked"
    case unlocked = "walleyCheckoutUnlocked"
    case resumed = "walleyCheckoutResumed"
    case shippingUpdated = "walleyCheckoutShippingUpdated"
    case purchaseCompleted = "walleyCheckoutPurchaseCompleted"
}
