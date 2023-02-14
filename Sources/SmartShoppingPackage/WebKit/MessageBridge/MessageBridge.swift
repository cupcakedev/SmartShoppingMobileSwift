//
//  MessageBridge.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 06.01.2023.
//

import WebKit


var newMessage: Any?
var lastMessage: Any?
var objectCount = 0
var countObjects = false
var initShowCustomizer = false

extension SmartShopping: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        var decodedMessage: Message?
        if message.name == Constants.messageBridgeKey{
            if let string = message.body as? String {
                decodedMessage = try decodeMessage(message: string)
            }
            if decodedMessage != nil {
                messageListeners.forEach { $0(decodedMessage!) }
                lastMessage = newMessage
                newMessage = message.json
            }
        }
    }
    
    func decodeMessage(message: String) -> Message? {
        if let data = message.data(using: .utf8) {
            if let decodedData = try? JSONDecoder().decode(Message.self, from:data) {
                return decodedData
            }
        }
        return nil
    }
    
    // send message(json) to webView
    func sendMessage(message: Codable) {
        if let JSONData = try? JSONEncoder().encode(message) {
            let JSONString = String(data: JSONData, encoding: .ascii)
            self.webView.evaluateJavaScript("""
                window.dispatchEvent(new CustomEvent("\(Constants.messageBridgeEvent)", {
                    detail: \(JSONString ?? "{}")
                  }));
             """)
        }
    }
    
    func addMessageSentListener(_ listener: @escaping (_ nMessage: Message) -> Void) {
        messageListeners.append(listener)
    }
}

extension WKScriptMessage {
    var json: [String: Any] {
        if let string = body as? String,
           let data = string.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let dict = object as? [String: Any] {
            return dict
        } else if let object = body as? [String: Any] {
            return object
        }
        return [:]
    }
}
