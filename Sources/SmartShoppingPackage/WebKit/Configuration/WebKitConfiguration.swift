//
//  WebKitConfiguration.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 06.01.2023.
//

import WebKit

extension SmartShopping {
    
    public func initWebView() {
        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
        view.addSubview(webView)
        webView.frame = self.view.frame
        webView.uiDelegate = self
        webView.configuration.applicationNameForUserAgent = userAgent
        webView.customUserAgent = userAgent
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false
        webView.configuration.userContentController.add(self, name: Constants.messageBridgeKey)
        webView.load(URLRequest(url: URL(string: Constants.initUrl)!))
        webViewURLObserver = webView.observe(\.url, options: .new) { [weak self] webView, change in
            self?.urlDidChange("\(String(describing: change.newValue))") }
    }
    
}
