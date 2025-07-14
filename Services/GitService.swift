//
//  GitService.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation

class GitService {
    @discardableResult
    static func runShell(_ command: String) -> String {
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func switchTo(profile: GitProfile) {
        runShell("git config --global user.name \"\(profile.name)\"")
        runShell("git config --global user.email \"\(profile.email)\"")
        runShell("ln -sf \(profile.sshKeyPath) ~/.ssh/id_rsa")
    }

    static func currentGitConfig() -> String {
        return runShell("git config --global --list")
    }

    static func readCurrentProfile() -> CurrentGitConfig {
        let output = runShell("git config --global --list")
        var name = ""
        var email = ""
        print("CURRENT CONFIG: \(output)")
        for line in output.components(separatedBy: "\n") {
            if line.hasPrefix("user.name=") {
                name = String(line.dropFirst("user.name=".count)) // ⚠️ This is incorrect
            } else if line.hasPrefix("user.email=") {
                email = String(line.dropFirst("user.email=".count)) // ⚠️ Also incorrect
            }
        }

        // String splitting to get user.name
        if name.isEmpty || email.isEmpty {
            for line in output.components(separatedBy: "\n") {
                let parts = line.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { continue }
                if parts[0] == "user.name" {
                    name = String(parts[1])
                } else if parts[0] == "user.email" {
                    email = String(parts[1])
                }
            }
        }

        let sshTarget = runShell("readlink ~/.ssh/id_rsa").trimmingCharacters(in: .whitespacesAndNewlines)
        let fullSSHPath = sshTarget.isEmpty ? nil : ("~/.ssh/" as NSString).appendingPathComponent(sshTarget)

        return CurrentGitConfig(name: name, email: email, sshKeyPath: fullSSHPath)
    }


    static func fullGitConfig() -> [GitConfigEntry] {
        let output = runShell("git config --list --show-origin")
        var entries: [GitConfigEntry] = []

        for line in output.components(separatedBy: "\n") {
            if line.hasPrefix("file:") {
                let parts = line.components(separatedBy: "\t")
                if parts.count == 2 {
                    let origin = parts[0].replacingOccurrences(of: "file:", with: "")
                    let keyValue = parts[1].components(separatedBy: "=")
                    if keyValue.count == 2 {
                        entries.append(GitConfigEntry(
                            key: keyValue[0],
                            value: keyValue[1],
                            origin: origin
                        ))
                    }
                }
            }
        }

        return entries
    }
}
