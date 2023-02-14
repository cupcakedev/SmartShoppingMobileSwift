//
//  URLDidChange.swift
//  SmartshoppingMobile
//
//  Created by Lenad on 06.01.2023.
//

extension String {
    func clean() -> String {
        var url = self.replacingOccurrences(of: "Optional", with: "")
        let brackets: Set<Character> = ["(", ")"]
        url.removeAll(where: { brackets.contains($0) })
        return url
    }
}
