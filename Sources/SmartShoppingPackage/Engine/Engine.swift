//
//  SmartShoppingCore.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation
import WebKit

public protocol SmartShoppingEventsDelegate {
    /**
     Called when a checkout state is received.
     
     - Parameters:
     - checkoutState: The checkout state.
     */
    func didReceiveCheckoutState(checkoutState: EngineCheckoutState)
    /**
     Called when an engine configuration is received.
     
     - Parameters:
     - engineConfig: The engine configuration.
     */
    func didReceiveConfig(engineConfig: EngineConfig)
    /**
     Called when a final cost has been calculated.
     
     - Parameters:
     - finalCost: The final cost.
     */
    func didReceiveFinalCost(finalCost: EngineFinalCost)
    /**
     Called when promo codes have been detected.
     
     - Parameters:
     - promoCodes: The promo codes.
     */
    func didReceivePromocodes(promoCodes: PromoCodes)
    /**
     Called when there is a change in the engine's progress.
     
     - Parameters:
     - value: The progress value.
     - progress: The engine's progress state.
     */
    func didReceiveProgress(value: ProgressStatus, progress: EngineState)
    
    /**
     Called when the engine detects a new promo code.
     
     - Parameters:
     - currentCode: The current promo code.
     */
    func didReceiveCurrentCode(currentCode: CurrentCode)
    /**
     Called when the engine detects the best promo code.
     
     - Parameters:
     - bestCode: The best promo code.
     */
    func didReceiveBestCode(bestCode: BestCode)
    /**
     Called when the engine detects a state change in the detection process.
     
     - Parameters:
     - detectState: The detection state.
     */
    func didReceiveDetectState(detectState: EngineDetectState)
    /**
     Called when the engine detects a change in the checkout process.
     
     - Parameters:
     - value: The checkout value.
     - engineState: The engine's state.
     */
    func didReceiveCheckout(value: Bool, engineState: EngineState)
}

public class Engine {
    let storage = Storage()
    var delegate: SmartShoppingEventsDelegate?
    
    let clientID: String
    let key: String
    let promoCodes: [String]
    let sendMessage:  (_ message: Codable) -> Void
    let evaluateJavaScript:  (_ js: String) async -> Void
    
    
    /**
     The `Engine` class is the main object used to control the Smart Shopping engine. It holds the configuration settings, promocodes, and other related data for the engine. It also provides methods to start the engine and handle callbacks.
     
     - Parameters:
     - clientID: A unique identifier for the client.
     - key: The API key to use for authentication.
     - promoCodes: An array of promo codes to use when applying discounts.
     - sendMessage: A closure to send messages to the client application.
     - evaluateJavaScript: A closure to evaluate JavaScript code on the webpage.
     */
    public init(clientID: String, key: String, promoCodes: [String], sendMessage: @escaping (Codable) -> Void, evaluateJavaScript: @escaping (String) async -> Void) {
        self.clientID = clientID
        self.key = key
        self.promoCodes = promoCodes
        self.sendMessage = sendMessage
        self.evaluateJavaScript = evaluateJavaScript
    }
    
    /**
     The `startEngine` method starts the SmartShopping engine for a given URL and promocodes. It determines if the URL is a checkout page, and if so, initializes the engine with the appropriate configuration. The method also sends initialization messages to the client application. 
     
     - Parameters:
     - url: The URL of the webpage to start the engine on.
     - codes: An array of promo codes to use when applying discounts.
     */
    public func startEngine(url: String, codes: [String]) async {
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
    
    /**
     This method fetch the platform configs from the server and prepares the selectors. It should be called after initializing the class.
     */
    func install() async {
        storage.shops = await requireShops()
        storage.defaultConfigs = await requireDefaultConfig()
        prepareDefaultSelectors()
    }
    
    /**
     This method initialize the SmartShopping engine in webView
     
     */
    public func initEngine() async {
        let js = """
              if (window && !window.smartShoppingEngine) {
                  window.smartShoppingEngine = new SmartShopping.Engine();
                  console.log("smartShoppingEngine", smartShoppingEngine)
                  window.sendMessageToNative = function sendMessageToNative(event, message) {
                      console.log("sendMessageToNative", event);
                      console.log(message);
                      window.webkit.messageHandlers["\(Constants.messageBridgeKey)"].postMessage(JSON.stringify({event, message}));
                   
                  };
        
                  smartShoppingEngine.subscribe({
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
             }
        """
        await evaluateJavaScript(js)
    }
    
    
    /**
     This method analyzes the checkout page and starts collecting information
     
     */
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
    
    
    /**
     This method starts to detect if the user is trying to enter his promo code
     
     */
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
    
    /**
     This method is used to notify the SmartShopping that the slider has been opened, in order to collect statistics. It should be called before the slider is shown to ensure accurate statistics are collected.
     
     */
    public func notifyAboutShowModal() async {
        let js = "smartShoppingEngine.notifyAboutShowModal()"
        await evaluateJavaScript(js)
    }
    
    /**
     This method is used to notify SmartShopping that the slider has been closed, in order to collect statistics. It should be called before the slider is closed to ensure accurate statistics are collected.
     
     */
    public func notifyAboutCloseModal() async {
        let js = "smartShoppingEngine.notifyAboutCloseModal()"
        await evaluateJavaScript(js)
    }
    
    /**
     This method applies promo codes and stores the results into the internal execution context.
     
     */
    public func apply() async {
        let js = "return await smartShoppingEngine.apply()"
        await evaluateJavaScript(js)
    }
    
    /**
     This method selects and applies the best available promo code for the current purchase.
     
     */
    public func applyBest() async {
        let js = "return await smartShoppingEngine.applyBest()"
        await evaluateJavaScript(js)
    }
    
    /**
     This method executes all stages of the SmartShopping process - inspect, apply, and applyBest.
     
     */
    public func fullCycle() async {
        let js = "return await smartShoppingEngine.fullCycle()"
        await evaluateJavaScript(js)
    }
    
    /**
     Use this method to abort the execution of the detect, apply, and applyBest stages.
     
     */
    public func abort() async {
        let js = "smartShoppingEngine.abort()"
        await evaluateJavaScript(js)
    }
    
    
    /// TODO: Implement automatic config updates every 60 minutes.
    /// TODO: Add logging to this method to aid in debugging.
    /// TODO: Update SDK to new version and ensure that `smartshopping_codes` message is included.
}
