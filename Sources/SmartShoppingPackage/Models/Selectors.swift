//
//  Selectors.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 10.01.2023.
//

import Foundation

public enum Selector: Codable {
    case selector (String)
    case shadowSelector (ShadowSelector)
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .selector(let v): try container.encode(v)
        case .shadowSelector(let v): try container.encode(v)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        do {
            self = .selector(try value.decode(String.self))
        } catch DecodingError.typeMismatch {
            self = .shadowSelector(try value.decode(ShadowSelector.self))
        }
    }
}

public struct ShadowSelector: Codable {
    public let shadowRoots: [String]
    public let target: String
}
