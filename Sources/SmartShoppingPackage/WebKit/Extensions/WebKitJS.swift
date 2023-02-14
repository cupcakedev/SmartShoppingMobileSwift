//
//  WebKitJS.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 06.01.2023.
//

import WebKit

extension WKWebView {
    
    func loadJS() {
        evaluateJavaScript(scriptString())
    }
    
    func scriptString() -> String {
        return getScriptString(fromFile: Constants.jsEntryFilename)
    }
    
    func getScriptString(fromFile: String) -> String {
        let url = Bundle.module.url(forResource: fromFile, withExtension: "js")!
        let source = try! String(contentsOf: url)
        return source
    }
}
