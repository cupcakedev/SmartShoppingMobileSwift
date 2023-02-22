//
//  SmartShopping.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation
import SwiftUI
import WebKit
import UIKit

/**
 A class that provides a view controller for the SmartShopping module.
 */
public class SmartShopping: UIViewController {
    var url = ""
    
    var webView: WKWebView?
    let clientID: String
    let key: String
    
    var promoCodes: [String] = []
    
    lazy public var engine = Engine(clientID: clientID, key: key,
                                    promoCodes: promoCodes,
                                    sendMessage: self.sendMessage,
                                    evaluateJavaScript: self.executeAsyncJavaScript)
    
    var messageListeners: [(_ nMessage: Message) -> Void] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Initializes the SmartShopping module.
     
     - Parameters:
     - clientID: The client ID.
     - key: The key.
     */
    public init(clientID: String, key: String) {
        self.clientID = clientID
        self.key = key
        super.init(nibName: nil, bundle: nil)
        addMessageSentListener(engine.messageHandler)
        Task {
            await engine.install()
        }
    }
    
    /**
     Initializes the SmartShopping module.
     
     - Parameters:
     - clientID: The client ID.
     - key: The key.
     - webView: The web view to install the module in.
     - delegate: The delegate to handle events related to the module.
     */
    public convenience init(clientID: String, key: String, webView: WKWebView, delegate: SmartShoppingEventsDelegate) {
        self.init(clientID: clientID, key: key)
        engine.delegate = delegate
    }
    
    /**
     Sets the controller and sets the delegate for SmartShoppingEventsDelegate. Important: This method must be called once after class initialization to establish the necessary connections with the web view and set the delegate.
     
     - Parameters:
     - webView: The web view to install the module in.
     - delegate: The delegate to handle events related to the module.
     */
    public func install(webView: WKWebView, delegate: SmartShoppingEventsDelegate) {
        webView.configuration.userContentController.add(self, name: Constants.messageBridgeKey)
        self.webView = webView
        engine.delegate = delegate
    }
    
    /**
     This method starts the SmartShopping engine by loading the appropriate configuration and initializing the SmartShopping flow. It first loads the SmartShopping code into the webview, and then starts the engine with the provided URL and promo codes. Note: that  method should only be called after the install method has been called and a valid webview is set.
     
     - Parameters:
     - url: The URL to start the engine with.
     - codes: An array of promo codes.
     */
    public func startEngine(url: String, codes: [String]) async {
        if let webView = self.webView {
            webView.loadJS()
            await engine.initEngine();
            await engine.startEngine(url: url, codes: codes)
        }
    }
}
