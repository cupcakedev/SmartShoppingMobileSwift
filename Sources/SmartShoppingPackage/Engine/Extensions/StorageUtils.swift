//
//  StorageUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 19.01.2023.
//

import Foundation

extension Engine {
    func locateShop(url: String) -> Merchant? {
        let locatedShop = self.storage.shops.first(where: { (merchant: Merchant) -> Bool in
            return url.range(of: merchant.shopUrl, options: .regularExpression, range: nil, locale: nil) != nil
        })
        return locatedShop
    }
    
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
    
    func locateConfig(url: String) async -> EngineConfig? {
        let locatedShop = self.locateShop(url: url)
        if locatedShop == nil {
            return nil
        }
        let locatedConfig = await loadConfig(shopId: locatedShop!.shopId)
        return locatedConfig
    }
    
}
