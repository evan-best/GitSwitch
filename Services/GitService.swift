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
                name = String(line.dropFirst("user.name=".count))
            } else if line.hasPrefix("user.email=") {
                email = String(line.dropFirst("user.email=".count))
            }
        }
        
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
        let fullSSHPath = sshTarget.isEmpty ? "~/.ssh/id_rsa" : ("~/.ssh/" as NSString).appendingPathComponent(sshTarget)
        
        return CurrentGitConfig(name: name, email: email, sshKeyPath: fullSSHPath)
    }
    
    static func extractAllGitProfiles() -> [GitProfile] {
        let name = runShell("git config --global user.name").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = runShell("git config --global user.email").trimmingCharacters(in: .whitespacesAndNewlines)
        let sshTarget = runShell("readlink ~/.ssh/id_rsa").trimmingCharacters(in: .whitespacesAndNewlines)
        let sshKeyPath = sshTarget.isEmpty ? "~/.ssh/id_rsa" : ("~/.ssh/" as NSString).appendingPathComponent(sshTarget)
        
        guard !name.isEmpty && !email.isEmpty else {
            return []
        }
        
        let profile = GitProfile(
            id: UUID(),
            label: "default",
            name: name,
            email: email,
            sshKeyPath: sshKeyPath
        )
        
        return [profile]
    }
    
    static func getAvailableSSHKeyLabel(baseLabel: String) -> (label: String, privatePath: String, publicPath: String) {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let sshFolder = "\(home)/.ssh"

        var attempt = 1
        var label = baseLabel
        var privatePath = "\(sshFolder)/id_rsa_\(label)"

        while FileManager.default.fileExists(atPath: privatePath) {
            attempt += 1
            label = "\(baseLabel) \(attempt)"
            privatePath = "\(sshFolder)/id_rsa_\(label)"
        }

        return (label, privatePath, privatePath + ".pub")
    }

    static func generateSSHKeyPair(baseLabel: String, email: String, completion: @escaping (String?, String?, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let (label, privatePath, publicPath) = getAvailableSSHKeyLabel(baseLabel: baseLabel)

            let script = """
            mkdir -p ~/.ssh
            ssh-keygen -t rsa -b 4096 -C "\(email)" -f "\(privatePath)" -N ""
            """

            _ = runShell(script)

            do {
                let privateKey = try String(contentsOfFile: privatePath)
                let publicKey = try String(contentsOfFile: publicPath)

                DispatchQueue.main.async {
                    completion(privateKey, publicKey, label)
                }
            } catch {
                print("❌ Failed to read generated key: \(error)")
                DispatchQueue.main.async {
                    completion(nil, nil, label)
                }
            }
        }
    }

}
