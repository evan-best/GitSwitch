//
//  AddProfileView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import SwiftUI

struct AddProfileView: View {
    @Environment(\.dismiss) var dismiss
    var onAdd: (GitProfile) -> Void

    @State private var label = ""
    @State private var name = ""
    @State private var email = ""
    @State private var sshPrivateKey = ""
    @State private var publicKey = ""
    @State private var setAsCurrent = true
    @State private var keyWasGenerated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Git Profile")
                .font(.title3)
                .bold()

            Group {
                Text("Label")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("e.g. work", text: $label)
                    .textFieldStyle(.roundedBorder)

                Text("Username")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Your username", text: $name)
                    .textFieldStyle(.roundedBorder)

                Text("Email")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("email@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 4) {
                    Text("SSH Private Key")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        if let url = URL(string: "https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("How to create an SSH key")
                }

                TextEditor(text: $sshPrivateKey)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3))
                    )

                Button("Generate SSH Key") {
                    generateKeypair()
                }
                .disabled(label.isEmpty || email.isEmpty)
            }

            if keyWasGenerated {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Public Key")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        Text(publicKey)
                            .font(.system(.caption, design: .monospaced))
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                            .contextMenu {
                                Button("Copy to Clipboard") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(publicKey, forType: .string)
                                }
                            }
                    }
                    .frame(height: 80)

                    Button("Download Public Key…") {
                        downloadPublicKey()
                    }
                }
            }

            Toggle("Set as current profile", isOn: $setAsCurrent)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    dismiss()
                }

                Button("Save") {
                    guard sshPrivateKey.contains("BEGIN OPENSSH PRIVATE KEY") else {
                        print("❌ SSH key is not in valid OpenSSH format")
                        return
                    }

                    let sshPath = ("~/.ssh/id_rsa_\(label)" as NSString).expandingTildeInPath

                    do {
                        try sshPrivateKey.write(toFile: sshPath, atomically: true, encoding: .utf8)
                        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: sshPath)
                    } catch {
                        print("❌ Failed to write SSH private key: \(error)")
                        dismiss()
                        return
                    }

                    let profile = GitProfile(id: UUID(), label: label, name: name, email: email, sshKeyPath: sshPath)

                    let keychain = KeychainService()
                    keychain.saveProfile(profile)

                    let savedProfiles = keychain.loadProfiles()
                    if savedProfiles.contains(where: { $0.id == profile.id }) {
                        print("✅ Profile successfully saved to Keychain.")
                    } else {
                        print("⚠️ Failed to confirm profile was saved.")
                    }

                    if setAsCurrent {
                        GitService.switchTo(profile: profile)
                    }

                    onAdd(profile)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(label.isEmpty || email.isEmpty || name.isEmpty || sshPrivateKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 360)
    }

    // MARK: - SSH Key Generation

    func generateKeypair() {
        let fileName = "id_rsa_\(label)"
        let privatePath = ("~/.ssh/\(fileName)" as NSString).expandingTildeInPath
        let publicPath = privatePath + ".pub"

        let script = """
        mkdir -p ~/.ssh
        ssh-keygen -t rsa -b 4096 -C "\(email)" -f "\(privatePath)" -N ""
        """

        _ = GitService.runShell(script)

        do {
            sshPrivateKey = try String(contentsOfFile: privatePath)
            publicKey = try String(contentsOfFile: publicPath)
            keyWasGenerated = true
        } catch {
            print("Failed to read generated key: \(error)")
        }
    }

    func downloadPublicKey() {
        let savePanel = NSSavePanel()
        savePanel.title = "Save Public Key"
        savePanel.nameFieldStringValue = "id_rsa_\(label).pub"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try publicKey.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Failed to save public key: \(error)")
                }
            }
        }
    }
}
