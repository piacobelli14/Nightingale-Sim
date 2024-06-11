//
//  SecurityManager.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 6/11/24.
//

import Foundation
import Security

func saveTokenToKeychain(token: String) {
    let tokenData = token.data(using: .utf8)!
    let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken",
        kSecValueData: tokenData
    ] as CFDictionary

    SecItemDelete(query)

    SecItemAdd(query, nil)
}

func loadTokenFromKeychain() -> String? {
    let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken",
        kSecReturnData: true,
        kSecMatchLimit: kSecMatchLimitOne
    ] as CFDictionary

    var dataTypeRef: AnyObject? = nil
    let status = SecItemCopyMatching(query, &dataTypeRef)

    if status == errSecSuccess {
        if let tokenData = dataTypeRef as? Data {
            return String(data: tokenData, encoding: .utf8)
        }
    }
    return nil
}

func deleteTokenFromKeychain() {
    let query = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken"
    ] as CFDictionary

    let status = SecItemDelete(query)
}

func isTokenExpired(token: String) -> Bool {
    let parts = token.split(separator: ".")
    if parts.count > 1 {
        let payload = parts[1]
        let decodedData = Data(base64Encoded: String(payload) + "==")
        if let json = try? JSONSerialization.jsonObject(with: decodedData!, options: []),
           let dict = json as? [String: Any],
           let exp = dict["exp"] as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: exp)
            return Date() > expirationDate
        }
    }
    return true
}
