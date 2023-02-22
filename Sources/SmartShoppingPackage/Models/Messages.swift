//
//  Messages.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 20.01.2023.
//

import Foundation

public enum Message: Codable {
    case checkMessage (CheckMessage)
    case initMessage (InitMessage)
    case persistMessage (PersistMessage)
    case clearPersistMessage (ClearPersistMessage)
    case configMessage (ConfigMessage)
    case engineConfig (EventMessage<EngineConfig>)
    case engineCheckoutState (EventMessage<EngineCheckoutState>)
    case engineFinalCost (EventMessage<EngineFinalCost>)
    case promoCodes (EventMessage<PromoCodes>)
    case engineDetectState (EventMessage<EngineDetectState>)
    case checkoutMessage (EventMessage<CheckoutMessage>)
    case progressMessage (EventMessage<ProgressMessage>)
    case currentCode (EventMessage<CurrentCode>)
    case bestCode (EventMessage<BestCode>)
    case logMessage (LogMessage)
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .configMessage(let v): try container.encode(v)
        case .checkMessage(let v): try container.encode(v)
        case .initMessage(let v): try container.encode(v)
        case .persistMessage(let v): try container.encode(v)
        case .clearPersistMessage(let v): try container.encode(v)
        case .engineConfig(let v): try container.encode(v)
        case .engineCheckoutState(let v): try container.encode(v)
        case .engineFinalCost(let v): try container.encode(v)
        case .promoCodes(let v): try container.encode(v)
        case .engineDetectState(let v): try container.encode(v)
        case .checkoutMessage(let v): try container.encode(v)
        case .progressMessage(let v): try container.encode(v)
        case .currentCode(let v): try container.encode(v)
        case .bestCode(let v): try container.encode(v)
        case .logMessage(let v): try container.encode(v)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        
        if let v = try? value.decode(CheckMessage.self) {
            self = .checkMessage(v)
            return
        } else if let v = try? value.decode(InitMessage.self) {
            self = .initMessage(v)
            return
        } else if let v = try? value.decode(PersistMessage.self) {
            self = .persistMessage(v)
            return
        } else if let v = try? value.decode(ClearPersistMessage.self) {
            self = .clearPersistMessage(v)
            return
        } else if let v = try? value.decode(ConfigMessage.self)  {
            self = .configMessage(v)
            return
        } else if (try? value.decode(EventMessage<EngineConfig>.self))?.event == "config" {
            let v = try! value.decode(EventMessage<EngineConfig>.self)
            self = .engineConfig(v)
            return
        } else if (try? value.decode(EventMessage<EngineCheckoutState>.self))?.event == "checkoutState" {
            let v = try! value.decode(EventMessage<EngineCheckoutState>.self)
            self = .engineCheckoutState(v)
            return
        } else if (try? value.decode(EventMessage<EngineFinalCost>.self))?.event == "finalCost" {
            let v = try! value.decode(EventMessage<EngineFinalCost>.self)
            self = .engineFinalCost(v)
            return
        } else if (try? value.decode(EventMessage<PromoCodes>.self))?.event == "promocodes" {
            let v = try! value.decode(EventMessage<PromoCodes>.self)
            self = .promoCodes(v)
            return
        } else if (try? value.decode(EventMessage<CheckoutMessage>.self))?.event == "checkout" {
            let v = try! value.decode(EventMessage<CheckoutMessage>.self)
            self = .checkoutMessage(v)
            return
        } else if (try? value.decode(EventMessage<ProgressMessage>.self))?.event == "progress" {
            let v = try! value.decode(EventMessage<ProgressMessage>.self)
            self = .progressMessage(v)
            return
        } else if (try? value.decode(EventMessage<EngineDetectState>.self))?.event == "detectState" {
            let v = try! value.decode(EventMessage<EngineDetectState>.self)
            self = .engineDetectState(v)
            return
        } else if (try? value.decode(EventMessage<CurrentCode>.self))?.event == "currentCode" {
            let v = try! value.decode(EventMessage<CurrentCode>.self)
            self = .currentCode(v)
            return
        } else if (try? value.decode(EventMessage<BestCode>.self))?.event == "bestCode" {
            let v = try! value.decode(EventMessage<BestCode>.self)
            self = .bestCode(v)
            return
        } else if (try? value.decode(LogMessage.self))?.type == "smartshopping_log" {
            let v = try! value.decode(LogMessage.self)
            self = .logMessage(v)
            return
        }
        
        throw Command.ParseError.notRecognizedType(value)
    }
    
    enum ParseError: Error {
        case notRecognizedType(Any)
    }
}

public struct CheckMessage: Codable {
    public let type: String
    public let defaultSelectors: [String: [Selector]]
}

public struct EventMessage<T: Codable>: Codable {
    public let event: String
    public let message: T
}

public struct InitMessage: Codable {
    public let type: String
    public let config: String?
    public let checkout: Bool
    public let promocodes: [String]
    public let persistedState: EnginePersistedState?
}

public struct PersistMessage: Codable {
    public let type: String
    public let persistedState: EnginePersistedState
}

public struct ClearPersistMessage: Codable {
    public let type: String
}

public typealias ConfigMessage = String
public typealias CurrentCode = String
public typealias BestCode = String
public typealias PromoCodes = [String]

public struct CheckoutMessage: Codable {
    public let value: Bool
    public let state: EngineState
}

public enum ProgressStatus: String, Codable {
    case inspectEnd = "INSPECT_END"
    case await = "AWAIT"
    case inactive = "INACTIVE"
    case apply = "APPLY"
    case applyEnd = "APPLY_END"
    case applyBest = "APPLY-BEST"
    case applyBestEnd = "APPLY-BEST_END"
    case fail = "FAIL"
    case success = "SUCCESS"
    case started = "STARTED"
    case detect = "DETECT"
    case detectEnd = "DETECT_END"
    case couponExtracted = "COUPON-EXTRACTED"
    case cancel = "CANCEL"
    case error = "ERROR"
}

public struct ProgressMessage: Codable {
    public let value: ProgressStatus
    public let state: EngineState
}

public struct LogMessage: Codable {
    public let type: String
    public let event: LogEvent
}

public struct LogEvent: Codable {
    public let type: String
    public let shop: String
    public let total: String?
    public let code: String?
    public let valid: Bool?
    public let message: String?
    public let discount: String?
    public let codes: String?
    public let layoutPage: String?
    
}



