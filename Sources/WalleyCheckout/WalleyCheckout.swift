import Foundation

final public class WalleyCheckout {
    
    public enum Environment {
        case production
        case test
        case ci
        case uat
    }
    
    private var frontendHost: String {
        switch Self.environment {
        case .production: return "https://checkout.walleypay.com"
        case .test: return "hhttps://checkout.uat.walleydev.com"
        case .ci: return "https://checkout.ci.walleydev.com"
        case .uat: return "https://checkout.uat.walleydev.com"
        }
    }
    
    public static var environment: Environment = .production
    
    /// Generate walley checkout script tag using public token.
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    public func createCheckoutSnippet(publicToken: String, actionColorHex: String? = nil, language: String? = nil, actionTextColor: String? = nil, padding: String? = nil, containerId: String? = nil ) -> String {
        """
        <script
          src="\(frontendHost)/walley-checkout-loader.js"
          data-token="\(publicToken)"
          data-webview="true"
          \(actionColorHex.map { "data-action-color=\"\($0)\"\n" } ?? "" )
          \(language.map { "data-lang=\"\($0)\"\n" } ?? "" )
            \(actionTextColor.map { "data-action-text-color=\"\($0)\"\n" } ?? "" )
                    \(padding.map { "data-padding=\"\($0)\"\n" } ?? "" )
                            \(containerId.map { "data-container-id=\"\($0)\"\n" } ?? "" )
        ></script>
        """
    }
    
    /// Generate html containing walley checkout script tag using public token.
    ///
    /// - Parameters:
    ///    - publicToken: Token generated using Walley backend service
    ///    - actionColor: Hexadecimal color code to change the background color of call to action buttons
    ///    - language: The display language
    public func createCheckoutHTML(publicToken: String, actionColor: String? = nil, language: String? = nil, actionTextColor: String? = nil, padding: String? = nil, containerId: String? = nil) -> String {
        """
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style='margin:0'>
          \(createCheckoutSnippet(publicToken: publicToken, actionColorHex: actionColor, language: language, actionTextColor: actionTextColor, padding: padding, containerId: containerId))
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
    case crmUpdated = "walleyCheckoutCrmUpdated"
    case orderValidationFailed = "walleyCheckoutOrderValidationFailed"
}
