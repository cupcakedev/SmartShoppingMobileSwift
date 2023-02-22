//
//  StorageUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 19.01.2023.
//

import Foundation

/**
 * Extension of Engine for storage-related utilities.
 */
extension Engine {
    
    /**
     Locates a Merchant for a given URL.
     
     - Parameters:
     - url: The URL to locate a Merchant for.
     
     - Returns: The located Merchant, if found.
     */
    func locateShop(url: String) -> Merchant? {
        let locatedShop = self.storage.shops.first(where: { (merchant: Merchant) -> Bool in
            return url.range(of: merchant.shopUrl, options: .regularExpression, range: nil, locale: nil) != nil
        })
        return locatedShop
    }
    
    /**
     Loads an EngineConfig from cache or the server.
     
     - Parameters:
     - shopId: The ID of the shop to load the EngineConfig for.
     
     - Returns: The loaded EngineConfig, or nil if it could not be loaded.
     */
    func loadConfig(shopId: String) async -> EngineConfig? {
        var result: EngineConfig?
        let cacheRequest = storage.cachedConfigs
        let targetConfig = cacheRequest[shopId]
        if (targetConfig != nil) && targetConfig?.timestamp ?? 0 > 6 * 3600 * 1000 {
            result = targetConfig!.config
        } else {
            let response = await self.requireShopConfig(shopId: shopId)
            result = response
            let cachedShopConfig = CachedEngineConfig(timestamp: Int(Date().timeIntervalSince1970 * 1000), config: result!)
            storage.addCachedConfig(id: shopId, config: cachedShopConfig)
        }
        return result
    }
    
    /**
     Locates the EngineConfig for a given URL.
     
     - Parameters:
     - url: The URL to locate the EngineConfig for.
     
     - Returns: The located EngineConfig, if found.
     */
    func locateConfig(url: String) async -> EngineConfig? {
        let locatedShop = self.locateShop(url: url)
        if locatedShop == nil {
            return nil
        }
        let locatedConfig = await loadConfig(shopId: locatedShop!.shopId)
        return locatedConfig
    }
    
    /**
     Prepares default selectors for later use.
     */
    func prepareDefaultSelectors() {
        var newObjects: [String: [Selector]] = [:]
        storage.defaultConfigs.forEach { config in
            newObjects[config.shopId] = config.selectorsToCheck
        }
        storage.defaultSelectors = newObjects
    }
    
}


