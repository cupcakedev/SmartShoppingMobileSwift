//
//  Merchant.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 10.01.2023.
//

import Foundation

public struct Merchant: Codable {
    public let shopName: String
    public let shopId: String
    public let shopUrl: String
    public let checkoutUrl: String
}
