//
//  ExecuteJS.swift
//  
//
//  Created by Lenad on 19.02.2023.
//

import Foundation

extension SmartShopping {
    func executeAsyncJavaScript(_ js: String) async {
        return await withCheckedContinuation { continuation in
            if let webView = self.webView {
                if #available(iOS 14.0, *) {
                    webView.callAsyncJavaScript(js, arguments: [:], in: nil, in: .page
                    ) { result in
                        switch(result) {
                        case .success(_):
                            continuation.resume()
                            break
                        case .failure(let error):
                            debugPrint(error)
                        }
                        
                    }
                } else {
                    webView.evaluateJavaScript("(async function() {\(js)})()") { result, error in
                        if let error = error {
                            debugPrint(error)
                            continuation.resume()
                        } else {
                            continuation.resume()
                        }
                    }
                }
            }
            
        }
    }
}
