//
//  PrepareUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 10.01.2023.
//

import Foundation

extension SmartShoppingEngine {
    func prepareDefaultSelectors() {
        var newObjects: [String: [Selector]] = [:]
        storage.defaultConfigs.forEach { config in
            newObjects[config.shopId] = config.selectorsToCheck
        }
        storage.defaultSelectors = newObjects
    }
}
