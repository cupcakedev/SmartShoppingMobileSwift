//
//  MessageBridge.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 06.01.2023.
//

import WebKit

extension SmartShopping: WKScriptMessageHandler {
    
    /**
     * Handler for messages received from the WKWebView.
     *
     * - Parameters:
     *   - userContentController: The user content controller that received the message.
     *   - message: The message that was received.
     */
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        var decodedMessage: Message?
        if message.name == Constants.messageBridgeKey{
            if let string = message.body as? String {
                decodedMessage = try decodeMessage(message: string)
            }
            if decodedMessage != nil {
                messageListeners.forEach { $0(decodedMessage!) }
            }
        }
    }
    
    /**
     * Decodes a message received from the WKWebView into a `Message` object.
     *
     * - Parameter message: The message to decode.
     * - Returns: A `Message` object representing the decoded message, or `nil` if the decoding fails.
     */
    func decodeMessage(message: String) -> Message? {
        if let data = message.data(using: .utf8) {
            if let decodedData = try? JSONDecoder().decode(Message.self, from:data) {
                return decodedData
            }
        }
        return nil
    }
    
    /**
     * Sends a message to the WKWebView in the form of a JSON-encoded `Codable` object.
     *
     * - Parameter message: The message to send.
     */
    func sendMessage(message: Codable) {
        if let JSONData = try? JSONEncoder().encode(message) {
            let JSONString = String(data: JSONData, encoding: .ascii)
            self.webView?.evaluateJavaScript("""
                window.dispatchEvent(new CustomEvent("\(Constants.messageBridgeEvent)", {
                    detail: \(JSONString ?? "{}")
                  }));
             """)
        }
    }
    
    /**
     * Adds a listener for messages that are sent to the WKWebView.
     *
     * - Parameter listener: A closure that will be called with the received `Message` object.
     */
    func addMessageSentListener(_ listener: @escaping (_ nMessage: Message) -> Void) {
        messageListeners.append(listener)
    }
}

extension WKScriptMessage {
    
    /**
     * Returns the body of the message as a dictionary, assuming it is a JSON-encoded string or dictionary.
     */
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
