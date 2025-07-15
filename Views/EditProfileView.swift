//
//  EditProfileView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    var profile: GitProfile
    var onSave: (GitProfile) -> Void

    @State private var label: String
    @State private var name: String
    @State private var email: String
    @State private var sshPrivateKey: String
    @State private var publicKey: String = ""
    @State private var keyWasGenerated = false

    init(profile: GitProfile, onSave: @escaping (GitProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _label = State(initialValue: profile.label)
        _name = State(initialValue: profile.name)
        _email = State(initialValue: profile.email)

        let expandedPath: String
        if profile.sshKeyPath.hasPrefix("~") {
            expandedPath = (profile.sshKeyPath as NSString).expandingTildeInPath
        } else {
            expandedPath = profile.sshKeyPath
        }

        if let contents = try? String(contentsOfFile: expandedPath) {
            _sshPrivateKey = State(initialValue: contents)
        } else {
            _sshPrivateKey = State(initialValue: "")
        }

        let pubPath = expandedPath + ".pub"
        if let pubKey = try? String(contentsOfFile: pubPath) {
            _publicKey = State(initialValue: pubKey)
            _keyWasGenerated = State(initialValue: true)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Git Profile")
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

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    dismiss()
                }

                Button("Save Changes") {
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

                    let updatedProfile = GitProfile(
                        id: profile.id,
                        label: label,
                        name: name,
                        email: email,
                        sshKeyPath: sshPath
                    )

                    let keychain = KeychainService()
                    keychain.deleteProfile(withID: profile.id)
                    keychain.saveProfile(updatedProfile)

                    onSave(updatedProfile)
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
        let base = label.replacingOccurrences(of: " ", with: "_")

        GitService.generateSSHKeyPair(baseLabel: base, email: email) { privateKey, publicKey, resolvedLabel in
            if let privateKey = privateKey, let publicKey = publicKey {
                self.label = resolvedLabel          // Update label in UI
                self.sshPrivateKey = privateKey
                self.publicKey = publicKey
                self.keyWasGenerated = true
            } else {
                print("❌ Key generation failed.")
                self.keyWasGenerated = false
            }
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

#Preview {
    EditProfileView(profile: GitProfile(id: UUID(), label: "Work", name: "work-user", email: "user@example.com", sshKeyPath: "path/to/key"), onSave: { _ in })
}
