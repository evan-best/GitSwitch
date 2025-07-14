//
//  GitProfile.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation

struct GitProfile: Identifiable, Codable {
    let id: UUID
    var label: String // e.g. "Work", "Personal"
    var name: String // Display name
    var email: String
    var sshKeyPath: String // Path to ssh key in keychain
}

