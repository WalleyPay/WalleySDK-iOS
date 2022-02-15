import Foundation

final public class WalleyCheckout {
    
    public enum Environment {
        case production
        case test
    }
    
    private let network: Network = .init()
    
    private var frontendHost: String {
        switch Self.environment {
        case .production: return "https://checkout.collector.se"
        case .test: return "https://checkout-uat.collector.se"
        }
    }
    
    private var backendHost: String {
        switch Self.environment {
        case .production: return "https://api.checkout.walleypay.com"
        case .test: return "https://api.checkout.uat.walleydev.com"
        }
    }
    
    public static var environment: Environment = .production
    
    public var credentials: Credentials? {
        set { network.credentials = newValue }
        get { network.credentials }
    }
    
    public func initCheckout(_ checkout: Checkout, completion: @escaping (Result<InitCheckoutData, Error>) -> Void) {
        let jsonBodyData = try! JSONEncoder().encode(checkout)
        let jsonBody = String(data: jsonBodyData, encoding: .utf8)!
        network.request(
            method: "POST",
            host: backendHost,
            path: "/checkout",
            httpBody: jsonBody
        ) { result in
            completion(result)
        }
    }
    
    public func createCheckoutSnippet(publicToken: String, actionColorHex: String? = nil, language: String? = nil) -> String {
        """
        <script
          src="\(frontendHost)/collector-checkout-loader.js"
          data-token="\(publicToken)"
          data-version="v2"
          \(actionColorHex.map { "data-action-color=\"\($0)\"\n" } ?? "" )
          \(language.map { "data-lang=\"\($0)\"\n" } ?? "" )
        ></script>
        """
    }
    
    public func createCheckoutHTML(publicToken: String, actionColorHex: String? = nil, language: String? = nil) -> String {
        """
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style='margin:0'>
          \(createCheckoutSnippet(publicToken: publicToken, actionColorHex: actionColorHex, language: language))
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
}
