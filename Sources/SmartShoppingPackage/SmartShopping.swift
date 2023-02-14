//
//  ViewController.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation
import SwiftUI
import WebKit
import UIKit

public protocol SmartShoppingEventsDelegate: EngineDelegate {
    func didChangeURL(nUrl: String) -> Void
}

public class SmartShopping: UIViewController, WKNavigationDelegate, WKUIDelegate, EngineDelegate {
    public let webView: WKWebView
    var url = ""
    let clientID: String
    let key: String
    let serverUrl: String = "https://api.smartshopping.ai"
    var promoCodes: [String] = []
    public var delegate: SmartShoppingEventsDelegate?
    
    lazy public var engine = SmartShoppingEngine(clientID: clientID, key: key, serverUrl: serverUrl,
                                                 promoCodes: promoCodes,
                                                 sendMessage: self.sendMessage,
                                                 evaluateJavaScript: {js in self.webView.evaluateJavaScript(js)})
    var messageListeners: [(_ nMessage: Message) -> Void] = []
    var webViewURLObserver: NSKeyValueObservation?
    
    public init(clientID: String, key: String) {
        self.webView = WKWebView()
        self.clientID = clientID
        self.key = key
        self.delegate = nil
        super.init(nibName: nil, bundle: nil)
        initWebView()
        addMessageSentListener(engine.messageHandler)
        engine.delegate = self
        Task {
            await engine.install()
        }
    }
    
    
    public convenience init(clientID: String, key: String, delegate: SmartShoppingEventsDelegate) {
        self.init(clientID: clientID, key: key)
        self.delegate = delegate
    }
    
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame = self.view.frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        super.viewDidLoad()
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.loadJS()
        Task {
            await engine.initEngine();
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("******** webView *******")
        
        delegate?.didChangeURL(nUrl: webView.url!.absoluteString)
    }
    
    func urlDidChange(_ urlString: String) {
        url = urlString.clean()
        print("******** urlDidChange *******")
//        delegate?.didChangeURL(nUrl: urlString)
    }
    
    public func startEngine(url: String, codes: [String]) async {
        await engine.startEngine(url: url, codes: codes)
    }
    
    public func didReceiveCheckoutState(checkoutState: EngineCheckoutState) {
        delegate?.didReceiveCheckoutState(checkoutState: checkoutState)
    }
    
    public func didReceiveConfig(engineConfig: EngineConfig) {
        delegate?.didReceiveConfig(engineConfig: engineConfig)
    }
    
    public func didReceiveFinalCost(finalCost: EngineFinalCost) {
        delegate?.didReceiveFinalCost(finalCost: finalCost)
    }
    
    public func didReceivePromocodes(promoCodes: PromoCodes) {
        delegate?.didReceivePromocodes(promoCodes: promoCodes)
    }
    
    public func didReceiveProgress(value: ProgressStatus, progress: EngineState) {
        delegate?.didReceiveProgress(value: value, progress: progress)
    }
    
    public func didReceiveCurrentCode(currentCode: CurrentCode) {
        delegate?.didReceiveCurrentCode(currentCode: currentCode)
    }
    
    public func didReceiveBestCode(bestCode: BestCode) {
        delegate?.didReceiveBestCode(bestCode: bestCode)
    }
    
    public func didReceiveDetectState(detectState: EngineDetectState) {
        delegate?.didReceiveDetectState(detectState: detectState)
    }
    
    public func didReceiveCheckout(value: Bool, engineState: EngineState) {
        delegate?.didReceiveCheckout(value: value, engineState: engineState)
    }
}

