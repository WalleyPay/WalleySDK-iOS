# Walley Checkout iOS SDK

Walley Checkout iOS SDK for native app integration.

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
    .package(url: "https://github.com/WalleyPay/WalleySDK-iOS.git", .upToNextMajor(from: "1.0.0"))
]
```

## Introduction

Walley Checkout provides a native UIView or UIViewController containing the Walley Checkout UI.

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

Load checkout using your generated token and present the view controller:

```
vc.loadCheckout(publicToken: "<Your token>")
present(vc, animated: true)
```

### Swedish BankID and Swish

In order to support Swedish BankID, Swish and Vipps, the app's `Info.plist` must contain `LSApplicationQueriesSchemes` with the following values:

```
...
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>bankid</string>
    <string>swish</string>
    <string>vipps</string>

</array>
...
```

### Test data

[Walley Checkout test data](https://dev.walleypay.com/docs/checkout/test-data)
