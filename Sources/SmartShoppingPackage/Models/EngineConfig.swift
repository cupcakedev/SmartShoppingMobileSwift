//
//  EngineConfig.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 09.01.2023.
//

import Foundation

public struct EngineConfig: Codable {
    public let version: Double
    public let taskId: String
    public let shopId: String
    public let shopName: String
    public let shopUrl: String
    public let checkoutUrl: String
    public let extendedLogs: Bool
    public let extendedReports: Bool
    public let inspect: [Command]
    public let detect: [Command]
    public let apply: [Command]
    public let applyBest: [Command]
    public let selectorsToCheck: [Selector]
}

public struct CachedEngineConfig: Codable {
    public let timestamp: Int
    public let config: EngineConfig
}

public struct EnginePersistedState: Codable {
    public let context: EngineExecContext
    public let finalCost: EngineFinalCost
    public let checkoutState: EngineCheckoutState
}

public struct EngineExecContext: Codable {
    public let code: String
    public let codeIsValid: Bool
    public let value: String?
    public let `return`: Int
    public let criticalError: Bool
    public let anchor: String?
    public let anchorCode: String?
    public let anchorStage: String?
}

public typealias EngineFinalCost = [String: Double]

public struct EngineCheckoutState: Codable {
    public let total: Double?
}

public struct EngineDetectState: Codable {
    public let userCode: String
    public let isValid: Bool
}

public struct EngineState: Codable {
    public let checkoutState: EngineCheckoutState
    public let finalCost: EngineFinalCost
    public let progress: String
    public let config: EngineConfig
    public let promocodes: PromoCodes
    public let detectState: EngineDetectState
    public let bestCode: String
    public let currentCode: String
    public let checkout: Bool
}






