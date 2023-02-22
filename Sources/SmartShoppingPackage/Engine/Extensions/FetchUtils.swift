//
//  FetchUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 09.01.2023.
//

import Foundation

extension Engine {
    enum FetchErrors: Swift.Error {
        case invalidUrl
        case requestError
        case unexpectedResponse
    }
    /**
     Retrieves a list of merchants from the server and decodes the response to an array of `Merchant`.
     
     - Returns: An array of `Merchant`.
     */
    func requireShops() async -> [Merchant] {
        do {
            let url = "\(Constants.serverUrl)/shop/urls?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let decodedData = try JSONDecoder().decode([Merchant].self, from:data)
            return decodedData
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    /**
     Retrieves an array of `EngineConfig` objects representing default configurations for all supported shops.
     
     - Returns: An array of `EngineConfig`.
     */
    func requireDefaultConfig() async -> [EngineConfig] {
        do {
            let url = "\(Constants.serverUrl)/shop/defaultConfigs?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let decodedData = try JSONDecoder().decode([EngineConfig].self, from:data)
            return decodedData
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    /**
     Retrieves an `EngineConfig` object representing the configuration for a specific shop.
     
     - Parameter shopId: The ID of the shop to retrieve the configuration for.
     - Returns: An `EngineConfig` object.
     */
    func requireShopConfig(shopId: String) async -> EngineConfig? {
        do {
            let url = "\(Constants.serverUrl)/shop/\(shopId)?clientID=\(clientID)"
            let (data, _) = try await self.fetch(url: url)
            let str = String(decoding: data, as: UTF8.self)
            let decodedData = try JSONDecoder().decode(EngineConfig.self, from:data)
            return decodedData
        } catch {
            debugPrint(error)
            return nil;
        }
    }
    
    /**
     This function is needed for logging events
     
     */
    func log(event: LogEvent) async -> Void {
        do {
            let url = "\(Constants.serverUrl)/logs"
            let parameters: [String : Any] = ["event": event, "clientID": clientID]
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            let (_, _) = try await fetch(url: url, method: "POST", body: jsonData)
        } catch {
            debugPrint(error)
        }
    }
    
    /**
     Fetches data from a given URL using a `URLRequest` with a specified HTTP method and HTTP body and returns the response data and URL response.
     
     - Parameters:
     - url: The URL to fetch data from.
     - method: The HTTP method to use for the request (e.g. "GET", "POST", etc.).
     - body: The data to include in the HTTP body of the request.
     - isReponseEncrypted: A boolean value indicating whether the response is encrypted.
     - Returns: A tuple of `Data` and `URLResponse`.
     - Throws: An error if the request fails or the status code is not 200.
     */
    func fetch(url: String, method: String = "GET", body: Data? = nil, isReponseEncrypted: Bool = true) async throws -> (Data, URLResponse) {
        guard let url = URL(string: url) else {
            throw FetchErrors.invalidUrl
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchErrors.requestError
        }
        if isReponseEncrypted {
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw FetchErrors.unexpectedResponse
            }
            let decryptedMessage = decrypt(message: jsonString)
            return (decryptedMessage.data(using: .utf8)!, response)
        }
        return (data, response)
    }
    
    
    /**
     Decrypts a given message using the `key` property as the password and returns the decrypted message.
     - Parameter message: The encrypted message to decrypt.
     - Returns: The decrypted message.
     */
    func decrypt(message: String) -> String {
        let AES = CryptoJS.AES()
        let decrypted = AES.decrypt(message, password: key)
        return decrypted
    }
}
