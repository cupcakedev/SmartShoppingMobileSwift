//
//  FetchUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 09.01.2023.
//

import Foundation

extension Engine {
    func requireShops() async -> [Merchant] {
        do {
            let url = "\(Constants.serverUrl)/shop/urls?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let decodedData = try JSONDecoder().decode([Merchant].self, from:data)
            return decodedData
        } catch {
            fatalError("Fatal error: \(error)")
        }
    }
    
    func requireDefaultConfig() async -> [EngineConfig] {
        do {
            let url = "\(Constants.serverUrl)/shop/defaultConfigs?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let str = String(decoding: data, as: UTF8.self)
            let decodedData = try JSONDecoder().decode([EngineConfig].self, from:data)
            return decodedData
        } catch {
            fatalError("Fatal error: \(error)")
        }
    }
    
    func requireShopConfig(shopId: String) async -> EngineConfig {
        do {
            let url = "\(Constants.serverUrl)/shop/\(shopId)?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let str = String(decoding: data, as: UTF8.self)
            print(str)
            let decodedData = try JSONDecoder().decode(EngineConfig.self, from:data)
            return decodedData
        } catch {
            fatalError("Fatal error: \(error)")
        }
    }
    
    func fetch(url: String, isReponseEncrypted: Bool = true) async throws -> (Data, URLResponse) {
        print("************************************************ FETCH ************************************************")
        guard let url = URL(string: url) else { fatalError("Incorrect URL") }
        let urlRequest = URLRequest(url:url)
        let (data, response) = try await URLSession.shared.data(for:urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {fatalError("Error while fetching data")}
        if isReponseEncrypted {
            guard let jsonString = String(data: data, encoding: .utf8) else { fatalError("Unexpected Response") }
            let decrypyedMessage = decrypt(message: jsonString)
            return (decrypyedMessage.data(using: .utf8)!, response)
        }
        return (data, response)
    }
}
