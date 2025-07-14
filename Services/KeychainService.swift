//
//  KeychainService.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation
import Security

class KeychainService {
    private let service = "com.evan-best.GitSwitch"

    // MARK: Save a profile
    func saveProfile(_ profile: GitProfile) {
        let key = profile.id.uuidString
        let data = try? JSONEncoder().encode(profile)

        guard let value = data else { return }

        // Delete old item if exists
        deleteProfile(withID: profile.id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: value
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    // MARK: Load all profiles
    func loadProfiles() -> [GitProfile] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }

        var profiles: [GitProfile] = []

        for item in items {
            if let data = item[kSecValueData as String] as? Data,
               let profile = try? JSONDecoder().decode(GitProfile.self, from: data) {
                profiles.append(profile)
            }
        }

        return profiles
    }

    // MARK: Delete a profile
    func deleteProfile(withID id: UUID) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: id.uuidString,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
