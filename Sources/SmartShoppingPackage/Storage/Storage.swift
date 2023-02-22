//
//  Storage.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation

/**
 A class for managing storage of engine configurations and cached data.
 */
class Storage {
    /// The filename for the cache file.
    let cacheFilename = "coreStorage.cache"
    
    /// Flag indicating whether the cache has already been read from disk.
    private var isAlreadyRead = false;
    
    /// An array of `Merchant` objects representing shops.
    var shops: [Merchant] = []
    
    /// An array of `EngineConfig` objects representing default configurations.
    var defaultConfigs: [EngineConfig] = []
    
    /// A dictionary containing default selectors for each selector key.
    var defaultSelectors: [String: [Selector]] = [:]
    
    /// An object representing persisted engine state.
    var persisted: EnginePersistedState?
    
    /// A private dictionary for holding cached engine configurations.
    private var _cachedConfigs: [String: CachedEngineConfig] = [:]
    
    /// A  computed property for getting and setting the cached engine configurations.
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
    
    /**
     Adds a cached engine configuration to the `_cachedConfigs` dictionary.
     
     - Parameters:
     - id: The ID of the cached engine configuration.
     - config: The cached engine configuration to add.
     */
    func addCachedConfig(id: String, config: CachedEngineConfig) {
        _cachedConfigs[id] = config
        saveToDisk()
    }
    
    /**
     Saves the cached engine configurations to disk.
     */
    func saveToDisk() {
        do {
            let jsonData = try JSONEncoder().encode(_cachedConfigs)
            try FilesManager.shared.save(fileNamed: cacheFilename, data: jsonData)
        } catch {
            
        }
    }
    
}
