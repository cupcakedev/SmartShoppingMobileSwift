# SmartShoppingPackage Integration Documentation

## Introduction:

This document provides the steps to integrate the `SmartShoppingPackage` into your iOS project.

#### Prerequisites:

- Xcode project with a minimum deployment target of `iOS 13.0`
- Access to the `clientID` and `key` that is provided to you after purchasing the `SmartShopping`

#### Install

Here are the steps to install the local `SmartShoppingPackage` in your Xcode project:

1. Open your Xcode project.
2. In the Project navigator, right-click on the project or target where you want to use the `SmartShoppingPackage`.
3. Choose "Add Packages..." from the context menu.
4. If you want to add a package from a repository:
    1. Paste "https://github.com/cupcakedev/SmartShoppingMobileSwift" into the text box in the opened dialog
    2. Click the "Add Package" button
    3. In the "Add Package" dialog, make sure the `SmartShoppingPackage` is selected, and click "Add Package".
5. If you want to add the library locally:
    1. Click the "Add local" button
    2. Select package folder and click the "Add Package" button
    3. Go to the project settings and find the "Frameworks, Libraries, and Embadded Content" section.
    4. Click on the plus button
    5. Choose SmartShoppingPackage and click "Add" button


Now you can import the `SmartShoppingPackage` in your Swift code using:
```swift
import SmartShoppingPackage
```

#### Integration:

1. Create a new instance of the `SmartShopping` class

To integrate the SDK into your project, you need to create an instance of the `SmartShopping` class. The class constructor takes the following arguments:

- clientID: A string value that is the user ID
- key: A string value that is the secret access key

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

3. Call the `install` method on the SmartShopping instance

Before starting SmartShopping flow, you need to set the `webView` and delegate to SmartShopping. To do this, call the `install` method

4. When changing the URL after loading the page, you need to start the smartshopping flow using the `startEngine` method. To track this event, use the `WKNavigationDelegate` delegate and the `func webView(WKWebView, didFinish: WKNavigation!)` function.

Full integration code:


```swift
import UIKit
import WebKit
import SmartShoppingPackage

class ViewController: UIViewController, WKNavigationDelegate, SmartShoppingEventsDelegate {
    let webView = WKWebView()
    let smartShopping: SmartShopping = SmartShopping(clientID: "demo", key: "very secret key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        webView.frame = self.view.frame
        webView.load(URLRequest(url: URL(string: "<shop_url>")!))
        webView.navigationDelegate = self // delegate for handle url change
        
        // connect webview to smartshopping engine and set delegate
        smartShopping.install(webView: webView, delegate: self)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // start SmartShopping flow when the page is loaded
        Task {
            await smartShopping.startEngine(url: webView.url!.absoluteString , codes: ["PROMO", "CODES"])
        }
    }

     func didReceiveCheckoutState(checkoutState: EngineCheckoutState) {
          // your implementation
     }
    
     // implement the other delegate methods
}
```

##### Using SwiftUI:

When using `WKWebView` in `SwiftUI`, you can implement a UIViewRepresentable view that conforms to the UIViewRepresentable protocol. This requires you to implement the following two methods:

*   `makeUIView(context:)`: This method returns an instance of the `WKWebView`. You can set the `navigationDelegate` of the webView to be the context's coordinator, and load a URL. Additionally, you can call the `SmartShopping.install()` method.
*   `updateUIView(_:context:)`: This method updates the view's content when necessary. You can leave it empty in this case.

Additionally, you need to create a `Coordinator` class that conforms to the `SmartShoppingEventsDelegate` and `WKNavigationDelegate` protocols. This class handles the interactions with the SmartShopping engine and receives the engine's events. 

Full integration code:

```swift
import SwiftUI
import WebKit
import SmartShoppingPackage

struct WebViewSmartShopping: UIViewRepresentable {
    let webView = WKWebView()
    var smartShopping: SmartShopping = SmartShopping(clientID: "demo", key: "very secret key")

    func makeCoordinator() - > Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) - > WKWebView {

        smartShopping.install(webView: webView, delegate: context.coordinator)

        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: URL(string: "<shop_url>") !))

        return webView;
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext < WebViewSmartShopping > ) {

    }

    class Coordinator: NSObject, SmartShoppingEventsDelegate, WKNavigationDelegate {
        let parent: WebViewSmartShopping
        
        init(_ parent: WebViewSmartShopping) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                Task {
                    await smartShopping.startEngine(url: webView.url!.absoluteString , codes: ["PROMO", "CODES"])
                }
            }
        }

        func didReceiveCheckoutState(checkoutState: EngineCheckoutState) {
            // your implementation
        }
        
        // implement the other delegate methods
    }
}
```

### API

#### Events

Summary of the delegate methods implemented in the `SmartShoppingEventsDelegate` protocol:

1. `didReceiveCheckoutState`
    Called when the SmartShopping engine receives a new checkout state.
    - Parameters:
        - checkoutState: The new checkout state received from the SmartShopping engine.
        
2. `didReceiveConfig`
    Called when the SmartShopping engine receives a new engine config.
    - Parameters:
        - engineConfig: The new engine config received from the SmartShopping engine.

3. `didReceiveFinalCost`
Called when the SmartShopping engine receives the final cost after applying promo codes.
    - Parameters:
        - finalCost: The final cost object received from the SmartShopping engine.

4. `didReceivePromocodes`
Called when promo codes have been detected.
    - Parameters:
        - promoCodes: The promo codes received from the backend API.

5. `didReceiveProgress`
Called when there is a change in the engine's progress.
    - Parameters:
        - value: The progress status value associated with the state change.
        - progress: The new progress state.
6. `didReceiveCurrentCode`
Called when the SmartShopping engine detects a current code.
    - Parameters:
        - currentCode: The new current code detected by the engine.
7. `didReceiveBestCode`
Called when the SmartShopping engine detects a new best code.
    - Parameters: 
        - bestCode: The new best code detected by the engine.
8. `didReceiveDetectState`
Called when the engine detects a state change in the detection process.
    - Parameters:
        - detectState: The new detect state detected by the engine.
9. `didReceiveCheckout`
Called when the engine detects a change in the checkout process.
    - Parameters:
        - value: The checkout value associated with the engine state.
        - engineState: The new engine state.

#### Engine

The instance of the SmartShopping class contains the `engine` field, which is an instance of the `Engine` class. The engine object provides the following methods for manipulating the SDK engine:

1. Inspect the checkout page: To analyze the checkout page and collect information about the products, shipping details, and discounts, you can call the inspect method on the engine instance.

```swift
smartShopping.engine.inspect()
```

2. Detect the custom coupon: To parse the checkout page for the entered custom coupon, you can call the detect method on the engine instance.

```swift
smartShopping.engine.detect()
```

3. Apply the promo codes: To apply the promo codes, you can call the apply method on the engine instance. The promocodes and the results will be stored in the internal execution context.

```swift
smartShopping.engine.apply()
```

4. Apply the best promo code: To choose and apply the best promo code, you can call the applyBest method on the engine instance.

```swift
smartShopping.engine.applyBest()
```

5. Execute all stages of the SmartShopping process - inspect, apply, and applyBest

```swift
smartShopping.engine.fullCycle()
```

6. Notify SmartShopping that the slider has been closed, in order to collect statistics. It should be called before the slider is closed to ensure accurate statistics are collected.

```swift
smartShopping.engine.notifyAboutCloseModal()
```

7. Notify the SmartShopping that the slider has been opened, in order to collect statistics. It should be called before the slider is shown to ensure accurate statistics are collected.

```swift
smartShopping.engine.notifyAboutShowModal()
```

The state of the engine and the results of these actions will be reported to the delegate through the `SmartShoppingEventsDelegate` protocol methods.

#### Types

Here's the documentation for the types listed:

###### `EngineConfig`
This struct contains the configuration information for the engine. It has the following fields:

*   `version`: a `Double` that represents the version number of the config.
*   `taskId`: a `String` that represents the task ID.
*   `shopId`: a `String` that represents the ID of the shop.
*   `shopName`: a `String` that represents the name of the shop.
*   `shopUrl`: a `String` that represents the URL of the shop.
*   `checkoutUrl`: a `String` that represents the URL of the checkout page.

###### `EngineFinalCost`
This type is a dictionary alias that maps promo code name keys (String) to Double values.

###### `EngineCheckoutState`
This struct represents the checkout state of the engine. It has one field:

*   `total`: an optional `Double` that represents the total cost of the checkout.

###### `EngineDetectState`
This struct represents the detection state of the engine. It has two fields:

*   `userCode`: a `String` that represents the user code.
*   `isValid`: a `Bool` that indicates whether the user code is valid.

###### `EngineState`
This struct represents the state of the engine. It has the following fields:

*   `checkoutState`: an instance of `EngineCheckoutState` that represents the checkout state.
*   `finalCost`: an instance of `EngineFinalCost` that represents the final cost of the engine.
*   `progress`: a `String` that represents the current progress of the engine.
*   `config`: an instance of `EngineConfig` that represents the engine's configuration.
*   `promocodes`: an array of `String` that contains the promo codes.
*   `detectState`: an instance of `EngineDetectState` that represents the detection state of the engine.
*   `bestCode`: a `String` that represents the best promotional code found by the engine.
*   `currentCode`: a `String` that represents the current promotional code being used by the engine.
*   `checkout`: a `Bool` that indicates whether the engine is currently checking out.

###### `ProgressStatus`
This enum represents the different possible states of progress for the engine. It has the following cases:

*   `inspectEnd`: The inspection has ended.
*   `await`: The engine is awaiting further action.
*   `inactive`: The engine is inactive.
*   `apply`: A promotional code is being applied.
*   `applyEnd`: The application of a promotional code has ended.
*   `applyBest`: The best promotional code is being applied.
*   `applyBestEnd`: The application of the best promotional code has ended.
*   `fail`: The engine has failed.
*   `success`: The engine has succeeded.
*   `started`: The engine has started.
*   `detect`: The engine is detecting the promotional codes.
*   `detectEnd`: The detection of the promotional codes has ended.
*   `couponExtracted`: A promotional code has been extracted.
*   `cancel`: The engine has been cancelled.
*   `error`: An error has occurred.

###### `ConfigMessage`
This type is an alias for a `String`.
###### `CurrentCode`
This type is an alias for a `String`.
###### `BestCode`
This type is an alias for a `String`.
###### `PromoCodes`
This type is an array of `String` that contains the promo codes.
