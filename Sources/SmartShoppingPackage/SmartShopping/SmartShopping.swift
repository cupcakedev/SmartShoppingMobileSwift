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
    var delegate: SmartShoppingEventsDelegate?
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
    
//    var webViewURLObserver: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(clientID: String, key: String) {
        self.clientID = clientID
        self.key = key
        self.delegate = nil
        super.init(nibName: nil, bundle: nil)
        // ??
        engine.delegate = self
        addMessageSentListener(engine.messageHandler)
        //
        Task {
            await engine.install()
        }
    }
    
    public convenience init(clientID: String, key: String,webView: WKWebView, delegate: SmartShoppingEventsDelegate) {
        self.init(clientID: clientID, key: key)
        self.delegate = delegate
    }
    
    public func install(webView: WKWebView, delegate: SmartShoppingEventsDelegate) {
        webView.configuration.userContentController.add(self, name: Constants.messageBridgeKey)
        self.webView = webView
        
        self.delegate = delegate
    }
    
//    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        webView.loadJS()
//        Task {
//            await engine.initEngine();
//        }
//    }
    
    //    func urlDidChange(_ urlString: String) {
    //        url = urlString.clean()
    //        print("******** urlDidChange *******")
    //        //        delegate?.didChangeURL(nUrl: urlString)
    //    }
    
    public func startEngine(url: String, codes: [String]) async {
        if let webView = self.webView {
            webView.loadJS()
            await engine.initEngine();
            await engine.startEngine(url: url, codes: codes)
        }
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
    
    func executeAsyncJavaScript(_ js: String) async {
        return await withCheckedContinuation { continuation in
            if let webView = self.webView {
                if #available(iOS 14.0, *) {
                    webView.callAsyncJavaScript(js, arguments: [:], in: nil, in: .page
                    ) { result in
                        switch(result) {
                        case .success(let results):
                            continuation.resume()
                            print("executeAsyncJavaScript")
                            print(results)
                            break
                        case .failure(let error):
                            print("executeAsyncJavaScript")
                            print(error)
                        }
                        
                    }
                } else {
                    webView.evaluateJavaScript("(async function() {\(js)})()") { result, error in
                        if let error = error {
                            print("Error: \(error)")
                            continuation.resume()
                        } else {
                            print("Result: \(String(describing: result))")
                            continuation.resume()
                        }
                    }
                }
            }
            
        }
    }
}
