# SmartShoppingPackage Integration Documentation

## Introduction:

This document provides the steps to integrate the `SmartShoppingPackage` into your iOS project.

#### Prerequisites:

- Xcode project with a minimum deployment target of `iOS 13.0`
- Access to the `clientID` and `key` that is provided to you after purchasing the `SmartShopping`

#### Steps:

1. Create a new instance of the `SmartShopping` class

To integrate the SDK into your project, you need to create an instance of the `SmartShopping` class. The class constructor takes the following arguments:

- clientID: A string value that is the user ID
- key: A string value that is the secret access key
- promoCodes: An array of promo codes (optional)
- delegate: An object that implements the `SmartShoppingEventsDelegate` protocol (described below)

2. Implement the `SmartShoppingEventsDelegate` protocol

The `SmartShoppingEventsDelegate` protocol contains the following methods:

```swift
protocol SmartShoppingEventsDelegate: class {
     func didReceiveCheckoutState(checkoutState: EngineCheckoutState)
     func didReceiveConfig(engineConfig: EngineConfig)
     func didReceiveFinalCost(finalCost: EngineFinalCost)
     func didReceivePromocodes(promoCodes: PromoCodes)
     func didReceiveProgress(value: String, progress: EngineState)
     func didReceiveCurrentCode(currentCode: CurrentCode)
     func didReceiveBestCode(bestCode: BestCode)
     func didReceiveDetectState(detectState: EngineDetectState)
     func didReceiveCheckout(value: Bool, engineState: EngineState)
}
```

Each method is triggered by a corresponding event such as the application of a custom coupon, the detection of a payment page, etc. You need to implement these methods in your `ViewController` to handle the events.

3. Load the `WKWebView`

Once you have created the `SmartShopping` instance and implemented the delegate, you can load a `URL` in the webView field of the SmartShopping object and add it to the view hierarchy.

```swift
class ViewController: UIViewController, SmartShoppingEventsDelegate {
     var smartShopping: SmartShopping?
    
     override func viewDidLoad() {
         super.viewDidLoad()
         smartShopping = SmartShopping(clientID: "demo", key: "very secret key", promoCodes: [], delegate: self, )
         smartShopping!.webView.load(URLRequest(url: URL(string: "https://www.asos.com")!))
         view.addSubview(smartShopping!.view)
         present(smartShopping!, animated: true, completion: nil)
     }
    
     func didReceiveCheckoutState(checkoutState: EngineCheckoutState) {
            // your implementation
     }
    
     // implement the other delegate methods
}
```

4. Interact with the `SmartShopping` engine

The instance of the SmartShopping class contains the `engine` field, which is an instance of the `SmartShoppingEngine` class. The engine object provides the following methods for manipulating the SDK engine:

1. Inspect the checkout page: To analyze the checkout page and collect information about the products, shipping details, and discounts, you can call the inspect method on the engine instance.

```swift
smartShopping?.engine.inspect()
```

2. Detect the custom coupon: To parse the checkout page for the entered custom coupon, you can call the detect method on the engine instance.

```swift
smartShopping?.engine.detect()
```

3. Apply the promo codes: To apply the promo codes, you can call the apply method on the engine instance. The promocodes and the results will be stored in the internal execution context.

```swift
smartShopping?.engine.apply()
```

4. Apply the best promo code: To choose and apply the best promo code, you can call the applyBest method on the engine instance.

```swift
smartShopping?.engine.applyBest()
```

The state of the engine and the results of these actions will be reported to the delegate through the `SmartShoppingEventsDelegate` protocol methods.


