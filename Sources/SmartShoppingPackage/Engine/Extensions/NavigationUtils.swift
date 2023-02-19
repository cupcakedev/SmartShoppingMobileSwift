//
//  NavigationUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 20.01.2023.
//

import Foundation

extension Engine {
    func isCheckoutPage(url: String, config: EngineConfig) -> Bool {
        return url.range(of: config.checkoutUrl, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
