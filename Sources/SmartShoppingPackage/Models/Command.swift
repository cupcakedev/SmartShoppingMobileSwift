//
//  Command.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 09.01.2023.
//

import Foundation

public enum Command: Codable {
    case commandIf (CommandIf)
    case commandWhile (CommandWhile)
    case iterationCodes (IterationCodes)
    case anchor (Anchor)
    case commandWait (CommandWait)
    case commandInsert (CommandInsert)
    case commandApply (CommandApply)
    case commandInteract (CommandInteract)
    case commandReturn (CommandReturn)
    case commandExtract (CommandExtract)
    case commandStore (CommandStore)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .commandIf(let v): try container.encode(v)
        case .commandExtract(let v): try container.encode(v)
        case .commandWhile(let v): try container.encode(v)
        case .iterationCodes(let v): try container.encode(v)
        case .anchor(let v): try container.encode(v)
        case .commandWait(let v): try container.encode(v)
        case .commandInsert(let v): try container.encode(v)
        case .commandApply(let v): try container.encode(v)
        case .commandInteract(let v): try container.encode(v)
        case .commandReturn(let v): try container.encode(v)
        case .commandStore(let v): try container.encode(v)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        
        if (try? value.decode(CommandIf.self))?.type == "command_if" {
            let v = try! value.decode(CommandIf.self)
            self = .commandIf(v)
            return
        }
        
        if (try? value.decode(CommandIf.self))?.type == "command_if" {
            let v = try! value.decode(CommandIf.self)
            self = .commandIf(v)
            return
        } else if (try? value.decode(CommandWhile.self))?.type == "command_while" {
            let v = try! value.decode(CommandWhile.self)
            self = .commandWhile(v)
            return
        } else if (try? value.decode(IterationCodes.self))?.type == "iteration_codes" {
            let v = try! value.decode(IterationCodes.self)
            self = .iterationCodes(v)
            return
        } else if (try? value.decode(Anchor.self))?.type == "anchor" {
            let v = try! value.decode(Anchor.self)
            self = .anchor(v)
            return
        } else if (try? value.decode(CommandWait.self))?.type == "command_wait" {
            let v = try! value.decode(CommandWait.self)
            self = .commandWait(v)
            return
        } else if (try? value.decode(CommandInsert.self))?.type == "command_insert" {
            let v = try! value.decode(CommandInsert.self)
            self = .commandInsert(v)
            return
        } else if (try? value.decode(CommandApply.self))?.type == "command_apply" {
            let v = try! value.decode(CommandApply.self)
            self = .commandApply(v)
            return
        } else if (try? value.decode(CommandInteract.self))?.type == "command_interact" {
            let v = try! value.decode(CommandInteract.self)
            self = .commandInteract(v)
            return
        } else if (try? value.decode(CommandReturn.self))?.type == "command_return" {
            let v = try! value.decode(CommandReturn.self)
            self = .commandReturn(v)
            return
        } else if (try? value.decode(CommandExtract.self))?.type == "command_extract" {
            let v = try! value.decode(CommandExtract.self)
            self = .commandExtract(v)
            return
        } else if (try? value.decode(CommandStore.self))?.type == "command_store" {
            let v = try! value.decode(CommandStore.self)
            self = .commandStore(v)
            return
        }
        
        throw Command.ParseError.notRecognizedType(value)
    }
    
    enum ParseError: Error {
        case notRecognizedType(Any)
    }
}

public struct CommandIf: Codable {
    public let type: String
    public let condition: Condition
    public let `do`: [Command]
    public let `else`: [Command]
}

public struct CommandWhile: Codable {
    public let type: String
    public let condition: Condition
    public let `do`: [Command]
}

public struct IterationCodes: Codable {
    public let type: String
    public let `do`: [Command]
}

public struct CommandWait: Codable {
    public let type: String
    public let response: [InteractResponse]?
    public let timeout: Int
}

public struct CommandInsert: Codable {
    public let type: String
    public let selector: Selector?
    public let value: String?
}

public struct CommandApply: Codable {
    public let type: String
    public let action: InteractAction
}

public struct CommandInteract: Codable {
    public let type: String
    public let action: InteractAction
    public let response: [InteractResponse]
    public let timeout: Int
}

public struct CommandReturn: Codable {
    public let type: String
    public let level: Int
}

public struct CommandStore: Codable {
    public let type: String
    public let target: String
}

public struct CommandExtract: Codable {
    public let type: String
    public let selector: Selector
    public let format: String
    public let target: String?
    public let cut: ExtractCut?
    public let codeIsValid: Bool?
}

public struct ExtractCut: Codable {
    public let position: String
    public let leftEdge: String?
    public let rightEdge: String?
}

public struct Anchor: Codable {
    public let type: String
    public let anchor: String
    public let place: String
}

public struct InteractResponse: Codable {
    public let type: String
    public let selector: Selector
}

public struct InteractAction: Codable {
    public let type: String
    public let selector: Selector
}


