//
//  CryptUtils.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 09.01.2023.
//

import Foundation
import CryptoKit

extension SmartShoppingEngine {
    func decrypt(message: String) -> String {
        let AES = CryptoJS.AES()
        let decrypted = AES.decrypt(message, password: key)
        return decrypted
    }
}
