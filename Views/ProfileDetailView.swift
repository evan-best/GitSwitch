//
//  ProfileDetailView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import SwiftUI

struct ProfileDetailView: View {
    let profile: GitProfile
    var onSwitch: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var publicKey: String = ""
    @State private var showEditProfile = false
    @State private var showKeygenError = false
    @State private var keygenErrorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile Details")
                .font(.title3)
                .bold()

            Text("Label: \(profile.label)")
            Text("Name: \(profile.name)")
            Text("Email: \(profile.email)")

            Divider()

            Text("Public Key")
                .font(.caption)
                .foregroundColor(.secondary)

            if !publicKey.isEmpty {
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
                .frame(height: 100)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Public key not found.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Generate Public Key") {
                        generatePublicKey()
                    }
                    .font(.caption)
                }
            }

            HStack {
                Button("Edit") {
                    showEditProfile = true
                }

                Button("Close", role: .cancel) {
                    dismiss()
                }

                Spacer()

                Button("Switch to This Profile") {
                    onSwitch()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 360)
        .onAppear(perform: loadPublicKey)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: profile) { updatedProfile in
                // In a real app, update profile in storage too
                loadPublicKey()
            }
        }
        .alert("Failed to Generate Key", isPresented: $showKeygenError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(keygenErrorMessage)
        }
    }

    private func loadPublicKey() {
        print("🔍 profile.sshKeyPath: \(profile.sshKeyPath)")
        
        var pubPath = profile.sshKeyPath + ".pub"
        if pubPath.hasPrefix("~") {
            pubPath = (pubPath as NSString).expandingTildeInPath
        }

        print("📁 Final public key path: \(pubPath)")

        if FileManager.default.fileExists(atPath: pubPath) {
            print("✅ Public key file exists.")
        } else {
            print("❌ Public key file does NOT exist.")
        }

        do {
            publicKey = try String(contentsOfFile: pubPath)
        } catch {
            print("❌ Could not read public key: \(error)")
            publicKey = ""
        }
    }


    private func generatePublicKey() {
        let base = profile.label.replacingOccurrences(of: " ", with: "_")

        GitService.generateSSHKeyPair(baseLabel: base, email: profile.email) { _, publicKey, _ in
            if let publicKey = publicKey {
                self.publicKey = publicKey
            } else {
                showKeygenError = true
                keygenErrorMessage = "Failed to generate SSH key pair. Make sure ssh-keygen is available and ~/.ssh is writable."
            }
        }
    }

}

#Preview {
    ProfileDetailView(
        profile: GitProfile(id: UUID(), label: "Work", name: "user-name", email: "user@work.com", sshKeyPath: "~/.ssh/id_rsa_Work"),
        onSwitch: {}
    )
}
