//
//  Condition.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 10.01.2023.
//

import Foundation

public enum Condition: Codable {
    case conditionElementVisible (ConditionElementVisible)
    case conditionLogic (ConditionLogic)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .conditionElementVisible(let v): try container.encode(v)
        case .conditionLogic(let v): try container.encode(v)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        do {
            self = .conditionElementVisible(try value.decode(ConditionElementVisible.self))
        } catch DecodingError.typeMismatch {
            self = .conditionLogic(try value.decode(ConditionLogic.self))
        }
    }
}

public struct ConditionElementVisible: Codable {
    public let type: String
    public let value: Selector?
    public let operands: [Condition]?
}

public struct ConditionLogic: Codable {
    public let type: String
    public let operands: String?
}
