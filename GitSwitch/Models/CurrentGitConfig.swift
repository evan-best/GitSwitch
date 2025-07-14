//
//  CurrentGitConfig.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation

struct CurrentGitConfig: Equatable {
    var name: String
    var email: String
    var sshKeyPath: String?

    func matches(profile: GitProfile) -> Bool {
        return profile.name == name &&
               profile.email == email &&
               normalize(path: profile.sshKeyPath) == normalize(path: sshKeyPath ?? "")
    }

    private func normalize(path: String) -> String {
        NSString(string: path).expandingTildeInPath
    }
}
