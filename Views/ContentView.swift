//
//  ContentView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//
import SwiftUI

struct ContentView: View {
    @State private var current: CurrentGitConfig = GitService.readCurrentProfile()
    @State private var profiles: [GitProfile] = KeychainService().loadProfiles()

    @State private var showAddProfile = false
    @State private var selectedProfile: GitProfile? = nil
    @State private var showDeleteConfirmation = false
    @State private var profileToDelete: GitProfile?

    private func importInitialProfileIfNeeded() {
        print("importInitialProfileIfNeeded called")
        if profiles.isEmpty {
            let imported = GitService.extractAllGitProfiles()
            print("extractAllGitProfiles returned: \(imported)")
            let keychain = KeychainService()
            for profile in imported {
                keychain.saveProfile(profile)
                print("Saved profile to keychain: \(profile)")
            }
            profiles = keychain.loadProfiles()
            print("Profiles loaded after save: \(profiles)")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GitSwitch")
                .font(.title3)
                .bold()

            Text("Profiles")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            ForEach(profiles) { profile in
                Button {
                    selectedProfile = profile
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.name)
                                .font(.subheadline)
                                .bold()
                            Text(profile.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if profile.email == current.email {
                            Text("Current")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        profileToDelete = profile
                        showDeleteConfirmation = true
                    }
                }
                .buttonStyle(.plain)
            }

            Divider()

            HStack {
                Button("Close") {
                    NSApp.terminate(nil)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Spacer()

                Button("Add Profile") {
                    showAddProfile = true
                }
                .font(.subheadline)
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)

        }
        .padding()
        .frame(width: 280)
        .onAppear {
            importInitialProfileIfNeeded()
        }
        .sheet(isPresented: $showAddProfile) {
            AddProfileView { newProfile in
                GitService.switchTo(profile: newProfile)
                current = GitService.readCurrentProfile()
                profiles = KeychainService().loadProfiles()
            }
        }
        .sheet(item: $selectedProfile) { profile in
            ProfileDetailView(profile: profile) {
                GitService.switchTo(profile: profile)
                current = GitService.readCurrentProfile()
                profiles = KeychainService().loadProfiles()
            }
        }
        .alert("Delete this profile?", isPresented: $showDeleteConfirmation, presenting: profileToDelete) { profile in
            Button("Delete", role: .destructive) {
                deleteProfile(profile)
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("This action cannot be undone.")
        }

    }

    private func deleteProfile(_ profile: GitProfile) {
        let keychain = KeychainService()
        keychain.deleteProfile(withID: profile.id)
        profiles = keychain.loadProfiles()
        current = GitService.readCurrentProfile()
    }
}



#Preview {
    ContentView()
}
