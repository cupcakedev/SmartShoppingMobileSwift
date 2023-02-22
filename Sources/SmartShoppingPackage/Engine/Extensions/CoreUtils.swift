//
//  CoreUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 20.01.2023.
//

import Foundation

extension Engine {
    /**
     Handles the received message and calls the appropriate delegate method based on the type of message.

     - Parameter nMessage: The received message to be handled.
     */
    public func messageHandler(nMessage: Message) {
        switch nMessage {
        case .configMessage(let config):
            defaultConfigInit(configId: config)
        case .checkMessage(_):
            break
        case .initMessage(_):
            break
        case .persistMessage(let persistMessage):
            persistState(state: persistMessage.persistedState)
        case .clearPersistMessage(_):
            clearPersistState()
        case .engineConfig(let eventMessage):
            delegate?.didReceiveConfig(engineConfig: eventMessage.message)
        case .engineCheckoutState(let eventMessage):
            delegate?.didReceiveCheckoutState(checkoutState: eventMessage.message)
        case .engineFinalCost(let eventMessage):
            delegate?.didReceiveFinalCost(finalCost: eventMessage.message)
        case .promoCodes(let eventMessage):
            delegate?.didReceivePromocodes(promoCodes: eventMessage.message)
        case .engineDetectState(let eventMessage):
            delegate?.didReceiveDetectState(detectState: eventMessage.message)
        case .checkoutMessage(let eventMessage):
            delegate?.didReceiveCheckout(value: eventMessage.message.value, engineState: eventMessage.message.state)
        case .progressMessage(let eventMessage):
            delegate?.didReceiveProgress(value: eventMessage.message.value, progress: eventMessage.message.state)
        case .currentCode(let eventMessage):
            delegate?.didReceiveCurrentCode(currentCode: eventMessage.message)
        case .bestCode(let eventMessage):
            delegate?.didReceiveBestCode(bestCode: eventMessage.message)
        case .logMessage(let eventMessage):
            if (Constants.isLoggerEnable) {
                Task {
                    await self.log(event: eventMessage.event)
                }
            }
        }
        
    }
    
    /**
     Persists the given engine state to the persistent storage.

     - Parameter state: The engine state to be persisted.
     */
    func persistState(state: EnginePersistedState) {
        storage.persisted = state
    }
    
    /**
     Clears the persisted engine state from the persistent storage.
     */
    func clearPersistState() {
        storage.persisted = nil
    }
    
    /**
     Initializes the engine with the default configuration for the given `configId`.

     - Parameter configId: The ID of the configuration to be used for initialization.
     */
    func defaultConfigInit(configId: String) {
        let config = self.storage.defaultConfigs.first(where: { (config: EngineConfig) -> Bool in
            return config.shopId == configId
        })
        
        if let jsonConfigData = try? JSONEncoder().encode(config) {
            let jsonConfigString = String(data: jsonConfigData, encoding: .ascii)
            let initMessage = InitMessage(type: "smartshopping_init", config: jsonConfigString,
                                          checkout: true, promocodes: self.promoCodes, persistedState: nil)
            sendMessage(initMessage)
        }
    }
    
}
