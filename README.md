# Walley Checkout iOS SDK

Klarna Checkout iOS SKD for native app integration.

## Requirements

- Swift 5.5
- iOS 10 or later

## Documentation

[Walley Developer Portal](https://dev.walleypay.com/)

[Walley Checkout](https://dev.walleypay.com/docs/checkout/introduction/)

## Installation

Walley Checkout SDK for iOS uses Swift Package Manager. To add the SDK as a dependency, add the following lines to `Package.swift`

```
dependencies: [
    .package(url: "https://github.com/FutureMemories/WalleySDK-iOS.git", .upToNextMajor(from: "1.0.0"))
]
```

## Introduction

Walley Checkout provides a native UIView or UIViewController containing the Walley Checkout UI. Checkout data is provided when loading the view and once the purchase has been completed, you will be notified through a web request to an API URI of your choosing. Details about the purchase may then be acquired from the Checkout REST API.

## Prerequisites

First of all you will need access to our environments. Contact Walley Merchant Services to acquire the following access credentials:

- Username
- Shared Access key
- Store Id

## Environment

For testing and staging purposes, Walley Merchant Services will setup an account in the UAT environment where you can test your implementation before moving to production.

The credentials (username, shared access key and store ID) will differ between the environments.

There are two environments:

- **Production** (All purchases are real and real money will be involved in transactions)
- **Test** (No real money will be involved in transactions)

To set environment you set the static `environment` property on `WalleyCheckout`:

```
WalleyCheckout.environment = .test
```

## Integration

WalleyCheckout SDK provides a `WalleyCheckoutView` and a `WalleyCheckoutController`. Which one to use depends on your usecase.

### Setup using WalleyCheckoutController

Create the view controller

```
let vc = WalleyCheckoutController()
```

Set credentials provided by Walley

```
vc.credentials = Credentials(
    username: "your username",
    accessKey: "your accesskey"
)
```

Create a checkout configuration

```
let checkout = Checkout(
    storeId: 1234,
    countryCode: "SE",
    reference: "https://example.com/my-reference",
    merchantTermsUri: "https://example.com/merchant-purchase-terms",
    notificationUri: "https://example.com/my-notification-endpoint",
    cart: Cart(
        items: [
            CartItem(
                id: "123",
                description: "Sample description",
                unitPrice: 66,
                unitWeight: 2.43,
                quantity: 2,
                vat: 25,
                requiresElectronicId: true
            )
        ]
    ),
    privateCustomerPrefill: CustomerPrefill(
        email: "strongverification@walley.se",
        mobilePhoneNumber: "+46701234567",
        nationalIdentificationNumber: "197707070707",
        deliveryAddress: DeliveryAddress(
            firstName: "FirstName",
            lastName: "LastName",
            coAddress: "",
            address: "Address1",
            address2: "",
            postalCode: 12345,
            city: "City"
        )
    ),
    customFields: [
        CustomFieldGroup(
            id: "123",
            name: "Extra fields group header",
            metadata: [
                "Metadata1" : 999,
            ],
            localizations: nil,
            fields: [
                CustomField(
                    id: "456",
                    name: "Extra field",
                    type: .text()
                ),
                CustomField(
                    id: "789",
                    name: "Extra option",
                    type: .checkbox(defaultValue: false)
                )
            ]
        )
    ]
)
```

When your checkout object is set up all you need to do is load it and present the view controller:

```
vc.loadCheckout(checkout)
present(vc, animated: true)
```

### Test data

[Walley Checkout test data](https://dev.walleypay.com/docs/checkout/test-data)
