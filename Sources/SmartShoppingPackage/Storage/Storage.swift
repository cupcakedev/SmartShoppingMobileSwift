//
//  Storage.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation

class Storage {
    let cacheFilename = "coreStorage.cache"
    private var isAlreadyRead = false;
    var shops: [Merchant] = []
    var defaultConfigs: [EngineConfig] = []
    var defaultSelectors: [String: [Selector]] = [:]
    var persisted: EnginePersistedState?
    private var _cachedConfigs: [String: CachedEngineConfig] = [:]
    
    var cachedConfigs: [String: CachedEngineConfig] {
        set {
            _cachedConfigs = newValue
            saveToDisk()
        }
        get {
            if _cachedConfigs.isEmpty && !isAlreadyRead {
                do{
                    let data = try FilesManager.shared.read(fileNamed: cacheFilename)
                    let decoded = try JSONDecoder().decode([String: CachedEngineConfig].self, from: data)
                    _cachedConfigs = decoded
                    isAlreadyRead = true
                } catch {
                    saveToDisk()
                }
            }
            return _cachedConfigs
        }
    }
    
    func addCachedConfig(id: String, config: CachedEngineConfig) {
        _cachedConfigs[id] = config
        saveToDisk()
    }
    
    func saveToDisk() {
        do {
            let jsonData = try JSONEncoder().encode(_cachedConfigs)
            try FilesManager.shared.save(fileNamed: cacheFilename, data: jsonData)
        } catch {
            
        }
    }
    
}
