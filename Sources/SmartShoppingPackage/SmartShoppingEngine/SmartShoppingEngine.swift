//
//  SmartShoppingCore.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation
import WebKit

public protocol EngineDelegate {
    func didReceiveCheckoutState(checkoutState: EngineCheckoutState)
    func didReceiveConfig(engineConfig: EngineConfig)
    func didReceiveFinalCost(finalCost: EngineFinalCost)
    func didReceivePromocodes(promoCodes: PromoCodes)
    func didReceiveProgress(value: ProgressStatus, progress: EngineState)
    func didReceiveCurrentCode(currentCode: CurrentCode)
    func didReceiveBestCode(bestCode: BestCode)
    func didReceiveDetectState(detectState: EngineDetectState)
    func didReceiveCheckout(value: Bool, engineState: EngineState)
}

public class SmartShoppingEngine {
    let clientID: String
    let key: String
    let serverUrl: String
    let promoCodes: [String]
    let storage = Storage()
    var delegate: EngineDelegate?
    let sendMessage:  (_ message: Codable) -> Void
    let evaluateJavaScript:  (_ js: String) async -> Void
    
    
    init(clientID: String, key: String, serverUrl: String, promoCodes: [String], sendMessage: @escaping (Codable) -> Void, evaluateJavaScript: @escaping (String) -> Void) {
        self.clientID = clientID
        self.key = key
        self.serverUrl = serverUrl
        self.promoCodes = promoCodes
        self.sendMessage = sendMessage
        self.evaluateJavaScript = evaluateJavaScript
    }
    
    func startEngine(url: String, codes: [String]) async {
        var isCheckout = false
        let locatedConfig = await locateConfig(url: url)
        if locatedConfig != nil {
            isCheckout = self.isCheckoutPage(url: url, config: locatedConfig!)
        } else {
            let checkMessage = CheckMessage(type: "smartshopping_check", defaultSelectors: storage.defaultSelectors)
            sendMessage(checkMessage)
            return
        }
        do {
            let jsonConfigData = try JSONEncoder().encode(locatedConfig)
            let jsonConfigString = String(data: jsonConfigData, encoding: .ascii)
            let initMessage = InitMessage(type: "smartshopping_init", config: jsonConfigString, checkout: isCheckout, promocodes: codes, persistedState: storage.persisted)
            sendMessage(initMessage)
        } catch {
            
        }
    }
    
    
    func install() async {
        storage.shops = await requireShops()
        storage.defaultConfigs = await requireDefaultConfig()
        prepareDefaultSelectors()
    }
    
    public func initEngine() async {
        let js = """
              const smartShoppingEngine = new SmartShopping.Engine();
              console.log("smartShoppingEngine", smartShoppingEngine)
              function sendMessageToNative(event, message) {
                  console.log("sendMessageToNative", event);
                  console.log(message);
                  window.webkit.messageHandlers["\(Constants.messageBridgeKey)"].postMessage(JSON.stringify({event, message}));
               
              };
        
              const unbinders = smartShoppingEngine.subscribe({
                config: (value) => sendMessageToNative("config", value),
                checkoutState: (value) => sendMessageToNative("checkoutState",value),
                finalCost: (value) => sendMessageToNative("finalCost",value),
                promocodes: (value) => sendMessageToNative("promocodes",value),
                progress: (value, state) => sendMessageToNative("progress", {value, state}),
                currentCode: (value) => sendMessageToNative("currentCode", value),
                bestCode: (value) => sendMessageToNative("bestCode", value),
                detectState: (value) => sendMessageToNative("detectState", value),
                checkout: (value, state) => sendMessageToNative("checkout", {value, state})
              });
        """
        await evaluateJavaScript(js)
    }
    
    public func inspect() async {
        let js = """
                if (document.readyState === 'complete') {
                    smartShoppingEngine.inspect();
                } else {
                    const inspector = () => {
                        smartShoppingEngine.inspect();
                        document.removeEventListener('load', inspector);
                    };
                    document.addEventListener('load', inspector);
                }
        """
        await evaluateJavaScript(js)
    }
    
    public func detect() async {
        let js = """
               if (document.readyState === 'complete') {
                   smartShoppingEngine.detect();
               } else {
                   const detector = () => {
                       smartShoppingEngine.detect();
                       document.removeEventListener('load', inspector);
                   };
                   document.addEventListener('load', inspector);
               }
       """
        await evaluateJavaScript(js)
    }
    
    public func notifyAboutShowModal() async {
        let js = "smartShoppingEngine.notifyAboutShowModal()"
        await evaluateJavaScript(js)
    }
    
    public func abort() async {
        let js = "smartShoppingEngine.abort()"
        await evaluateJavaScript(js)
    }
    
    public func apply() async {
        let js = "smartShoppingEngine.apply()"
        await evaluateJavaScript(js)
    }
    
    public func applyBest() async {
        let js = "smartShoppingEngine.applyBest()"
        await evaluateJavaScript(js)
    }
}
