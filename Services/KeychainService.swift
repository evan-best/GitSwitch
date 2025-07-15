//
//  KeychainService.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation
import KeychainAccess

class KeychainService {
    private let keychain = Keychain(service: "com.evan-best.GitSwitch")

    func saveProfile(_ profile: GitProfile) {
        let key = profile.id.uuidString
        do {
            let data = try JSONEncoder().encode(profile)
            try keychain.set(data, key: key)
        } catch {
            print("Failed to save profile to Keychain: \(error)")
        }
    }

    func loadProfiles() -> [GitProfile] {
        var profiles: [GitProfile] = []

        do {
            for key in keychain.allKeys() {
                if let data = try? keychain.getData(key),
                   let profile = try? JSONDecoder().decode(GitProfile.self, from: data) {
                    profiles.append(profile)
                }
            }
        } catch {
            print("Failed to load profiles from Keychain: \(error)")
        }

        return profiles
    }

    func deleteProfile(withID id: UUID) {
        do {
            try keychain.remove(id.uuidString)
        } catch {
            print("Failed to delete profile from Keychain: \(error)")
        }
    }
}
