import Foundation

public struct InitCheckoutData: Decodable {
    
    /// The publicToken is used to render the Checkout iframe.
    ///
    /// The public token has a limited lifetime of 168 hours (7 days).
    let publicToken: String
    
    /// The privateId is used to perform backend communication with the Checkout API for the given session.
    ///
    /// The privateId is used to acquire information for an ongoing or completed session for up to 6 months after it was created.
    ///
    /// The privateId is also used when modifying a session (e.g. cart update).
    ///
    /// Updates can be made for a session until it is completed or expiresAt has passed.
    let privateId: String
    
    /// The timestamp when this Checkout session will expire.
    ///
    /// After this timestamp the purchase cannot be completed, no updates to the cart can be performed and a new Checkout session must be initialized.
    let expiresAt: Date
    
    /// A shortcut link to this Checkout session.
    ///
    /// Used when distributing a Pay Link to a customer.
    let paymentUri: String
}

public struct Checkout: Encodable {
    public init(
        storeId: Int? = nil,
        countryCode: String,
        reference: String? = nil,
        settlementReference: String? = nil,
        redirectPageUri: String? = nil,
        hostedPaymentPageAbortedRedirectPageUri: String? = nil,
        merchantTermsUri: String,
        notificationUri: String,
        validationUri: String? = nil,
        profileName: String? = nil,
        cart: Cart,
        fees: [String : Fees]? = nil,
        privateCustomerPrefill: CustomerPrefill? = nil,
        customFields: [CustomFieldGroup]? = nil
    ) {
        self.storeId = storeId
        self.countryCode = countryCode
        self.reference = reference
        self.settlementReference = settlementReference
        self.redirectPageUri = redirectPageUri
        self.hostedPaymentPageAbortedRedirectPageUri = hostedPaymentPageAbortedRedirectPageUri
        self.merchantTermsUri = merchantTermsUri
        self.notificationUri = notificationUri
        self.validationUri = validationUri
        self.profileName = profileName
        self.cart = cart
        self.fees = fees
        self.privateCustomerPrefill = privateCustomerPrefill
        self.customFields = customFields
    }
    
    /// Received from Walley Merchant Services.
    ///
    /// The store ID is only required in the request when integrating multiple stores with Walley Checkout.
    let storeId: Int?
    
    /// The country code to use.
    ///
    /// `SE`, `NO`, `FI`, `DK` and `DE` is supported.
    let countryCode: String
    
    /// A reference to the order, i.e. order ID or similar. Note that the reference provided here will be shown to the customer on the invoice or receipt for the purchase.
    ///
    /// *Max 50 chars.*
    let reference: String?
    
    /// Set this if you would like to group your settlement reports based on this value. Can for example be used when you have several shops connected to one storeId and want purchases to be grouped by individual shops.
    ///
    /// *Max 50 chars.*
    ///
    /// To use this feature you must contact Merchant Services to setup Settlement Settings on this specific Store ID
    let settlementReference: String?
    
    /// If set, the browser will redirect to this page once the purchase has been completed. Used to display a thank-you-page for the end user. Hereafter referred to as the purchase confirmation page.
    ///
    /// Required if the Store is an `InStore` type.
    let redirectPageUri: String?
    
    /// If set and rendering a hosted payment page, a go back button will appear for the customer and if pressed, the checkout session will be deleted and the browser will redirect to this page.
    let hostedPaymentPageAbortedRedirectPageUri: String?
    
    /// The page to which the Checkout will include a link for customers that wish to view the merchant terms for purchase.
    let merchantTermsUri: String
    
    /// The endpoint to be called whenever an event has occurred in the Walley Checkout that might be of interest.
    ///
    /// For example, this callback is typically used to create an order in the merchant's system once a purchase has been completed.
    ///
    /// Use `HTTPS` here for security reasons.
    let notificationUri: String
    
    /// Specify this uri when you want us to make an extra backend call to validate the articles during purchase.
    ///
    /// Use `HTTPS` here for security reasons.
    let validationUri: String?
    
    /// A name that referes to a specific settings profile.
    ///
    /// The profiles are setup by Merchant Services, please contact them for more information help@walley.se
    let profileName: String?
    
    /// The initial ``Cart`` object with items to purchase
    let cart: Cart
    
    /// Shipping fee
    let fees: [String : Fees]?
    
    /// Customer information for identification
    let privateCustomerPrefill: CustomerPrefill?
    
    /// The customFields array allows you to optionally provide a blueprint for fields of your choosing to be rendered inside the checkout.
    ///
    /// These can be things like consent for newsletter or comments.
    ///
    /// It will be rendered in it's own section after the payment methods.
    ///
    /// You can specify multiple groups that will be rendered as their own separate sections, and the name field will set the header.
    ///
    /// We recommend not to have a name present if you only have one group. Each group can contain fields.
    ///
    /// We currently support checkboxes (shown as animated switches) and text fields. They may have a default value.
    ///
    /// Every group and field can also contain overriding localization information for markets with multiple languages, or to simplify with one configuration regardless of the current session language.
    let customFields: [CustomFieldGroup]?
}

/// The cart object contains an array of ``CartItem``. Please note that at least one article has to be included in order to initialize a checkout session.
///
/// Each item in the cart is identified by a unique identifier. The identifier used depends on which PaymentService version is used to active the purchase.
public struct Cart: Encodable {
    public init(
        items: [CartItem],
        shippingProperties: ShippingProperties? = nil
    ) {
        self.items = items
        self.shippingProperties = shippingProperties
    }
    
    let items: [CartItem]
    let shippingProperties: ShippingProperties?
}

public struct CartItem: Encodable {
    public init(
        id: String,
        description: String,
        unitPrice: Double,
        unitWeight: Double? = nil,
        quantity: Int,
        vat: Double,
        requiresElectronicId: Bool? = nil,
        sku: String? = nil
    ) {
        self.id = id
        self.description = description
        self.unitPrice = unitPrice
        self.unitWeight = unitWeight
        self.quantity = quantity
        self.vat = vat
        self.requiresElectronicId = requiresElectronicId
        self.sku = sku
    }
    
    /// The article id or equivalent.
    ///
    /// *Max 50 characters.*
    ///
    /// Values are trimmed from leading and trailing white-spaces. Shown on the invoice or receipt.
    let id: String
    
    /// Cart item description
    ///
    /// Descriptions longer than 50 characters will be truncated. Values are trimmed from leading and trailing white-spaces. Shown on the invoice or receipt.
    let description: String
    
    /// The unit price of the article including VAT.
    ///
    /// Positive and negative values allowed.
    ///
    /// *Max 2 decimals*, i.e. `100.00`
    let unitPrice: Double
    
    /// The weight of the article.
    ///
    /// Only positive values are allowed (including zero)
    let unitWeight: Double?
    
    /// Quantity of the article.
    ///
    /// Allowed values are `1` to `99999999`.
    let quantity: Int
    
    /// The VAT of the article in percent.
    ///
    /// Allowed values are `0` to `100`.
    ///
    /// *Max 2 decimals*, i.e. `25.00`
    let vat: Double
    
    /// When set to true it indicates that a product needs strong identification and the customer will need to strongly identify themselves at the point of purchase using electronic id such as Mobilt BankID.
    ///
    /// An example would be selling tickets that are delivered electronically.
    ///
    /// This feature is supported for B2C and B2B on the Swedish, Norwegian and Finnish markets.
    let requiresElectronicId: Bool?
    
    /// A stock Keeping Unit is a unique alphanumeric code that is used to identify product types and variations.
    ///
    /// *Maximum allowed characters are 1024.*
    let sku: String?
}

public struct ShippingProperties: Encodable {
    public init(
        height: Int,
        width: Int,
        isBulky: Bool
    ) {
        self.height = height
        self.width = width
        self.isBulky = isBulky
    }
    
    let height: Int
    let width: Int
    let isBulky: Bool
}

/// The ``Fees`` object allows you to set a shipping fee.
///
/// The fee will be shown last on the receipt after all the cart items and also on the purchase confirmation page for a completed purchase.
public struct Fees: Encodable {
    public init(
        id: String,
        description: String,
        unitPrice: Double,
        vat: Double
    ) {
        self.id = id
        self.description = description
        self.unitPrice = unitPrice
        self.vat = vat
    }
    
    /// An id of the fee item.
    ///
    /// *Max 50 characters.*
    ///
    /// Values are trimmed from leading and trailing white-spaces.
    ///
    /// Shown on the invoice or receipt.
    let id: String
    
    /// Fee description
    ///
    /// Descriptions longer than 50 characters will be truncated.
    ///
    /// Values are trimmed from leading and trailing white-spaces.
    ///
    /// Shown on the invoice or receipt.
    let description: String
    
    /// The unit price of the fee including VAT.
    ///
    /// Allowed values are `0` to `999999.99`.
    ///
    /// *Max 2 decimals*, i.e. `25.00`
    let unitPrice: Double
    
    /// The VAT of the fee in percent.
    ///
    /// Allowed values are `0` to `100`.
    ///
    /// *Max 2 decimals*, i.e. `25.00`
    let vat: Double
}

/// The `privateCustomerPrefill` object allows you to optionally provide customer information you might have if the customer is logged in into your site.
///
/// When we retrieve this information we try to identify the customer for a faster checkout experience. If we cannot identify the customer we prompt the user for further identification details.
///
/// The response and status code of the Initialize Checkout Session call is not affected by success or failure to identify the customer.
public struct CustomerPrefill: Encodable {
    public init(
        email: String? = nil,
        mobilePhoneNumber: String? = nil,
        nationalIdentificationNumber: String? = nil,
        deliveryAddress: DeliveryAddress? = nil
    ) {
        self.email = email
        self.mobilePhoneNumber = mobilePhoneNumber
        self.nationalIdentificationNumber = nationalIdentificationNumber
        self.deliveryAddress = deliveryAddress
    }
    
    /// The customer's email address.
    ///
    /// Required when identifying a user using a profile with DeliveryMode: Digital
    let email: String?
    
    /// The customer's mobile phone.
    ///
    /// When providing a number from a foreign country, it must have a valid prefix such as `+46` or `0046`.
    ///
    /// Required when identifying a user using a profile with DeliveryMode: Digital
    let mobilePhoneNumber: String?
    
    /// The customer's national identification number.
    let nationalIdentificationNumber: String?
    
    /// The customer's delivery address.
    let deliveryAddress: DeliveryAddress?
}

public struct DeliveryAddress: Encodable {
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        coAddress: String? = nil,
        address: String? = nil,
        address2: String? = nil,
        postalCode: Int? = nil,
        city: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.coAddress = coAddress
        self.address = address
        self.address2 = address2
        self.postalCode = postalCode
        self.city = city
    }
    
    let firstName: String?
    let lastName: String?
    let coAddress: String?
    let address: String?
    let address2: String?
    let postalCode: Int?
    let city: String?
}

public struct CustomFieldGroup: Encodable {
    public init(
        id: String,
        name: String? = nil,
        metadata: AnyEncodable? = nil,
        localizations: [String : CustomFieldGroupLocalization]? = nil,
        fields: [CustomField]
    ) {
        self.id = id
        self.name = name
        self.metadata = metadata
        self.localizations = localizations
        self.fields = fields
    }
    
    /// An id for the group.
    ///
    /// *Max 50 characters.*
    ///
    /// Values are trimmed from leading and trailing white-spaces.
    let id: String
    
    /// The header rendered above the group section
    let name: String?
    
    /// A metadata object for the group
    let metadata: AnyEncodable?
    
    /// Specify a different name and metadata for other languages (specified with ISO language codes)
    let localizations: [String : CustomFieldGroupLocalization]?
    
    /// An array of fields to render
    let fields: [CustomField]
}

public struct CustomField: Encodable {
    public init(
        id: String,
        name: String,
        type: CustomFieldType,
        localizations: [String : CustomFieldLocalization]? = nil,
        metadata: AnyEncodable? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.localizations = localizations
        self.metadata = metadata
    }
    
    /// An id for the group.
    ///
    /// *Max 50 characters.*
    ///
    /// Values are trimmed from leading and trailing white-spaces.
    let id: String
    
    
    /// The label for the field
    let name: String
    
    /// The type of field to be rendered. "Checkbox" or "Text".
    ///
    /// Can contain an optional default value for the field.
    let type: CustomFieldType
    
    /// Specify a different name/value/metadata for other languages (specified with ISO language codes)
    let localizations: [String : CustomFieldLocalization]?
    
    /// A metadata object for the group
    let metadata: AnyEncodable?
    
    enum CodingKeys: CodingKey {
        case id, name, type, value, metadata
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        switch type {
        case .checkbox(let defaultValue):
            try container.encode("Checkbox", forKey: .type)
            if let defaultValue = defaultValue {
                try container.encode(defaultValue, forKey: .value)
            }
        case .text(let defaultValue):
            try container.encode("Text", forKey: .type)
            if let defaultValue = defaultValue {
                try container.encode(defaultValue, forKey: .value)
            }
        }
        try container.encode(metadata, forKey: .metadata)
    }
}

public struct CustomFieldGroupLocalization: Encodable {
    public init(
        name: String? = nil,
        metadata: AnyEncodable? = nil
    ) {
        self.name = name
        self.metadata = metadata
    }
    
    let name: String?
    let metadata: AnyEncodable?
}

public struct CustomFieldLocalization: Encodable {
    public init(
        name: String? = nil,
        value: AnyEncodable? = nil,
        metadata: AnyEncodable? = nil
    ) {
        self.name = name
        self.value = value
        self.metadata = metadata
    }
    
    let name: String?
    let value: AnyEncodable?
    let metadata: AnyEncodable?
}

public enum CustomFieldType {
    case checkbox(defaultValue: Bool? = nil)
    case text(defaultValue: String? = nil)
}
