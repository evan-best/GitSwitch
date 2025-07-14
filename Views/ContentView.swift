//
//  ContentView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import SwiftUI

struct ContentView: View {
    @State private var current: CurrentGitConfig = GitService.readCurrentProfile()
    @State private var profiles: [GitProfile] = GitService.extractAllGitProfiles()
    @State private var showAddProfile = false

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
                Button(action: {
                    GitService.switchTo(profile: profile)
                    current = GitService.readCurrentProfile()
                    profiles = GitService.extractAllGitProfiles()
                }) {
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
                .buttonStyle(.plain)
            }

            Divider()

            Button("Add Profile") {
                showAddProfile = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 280)
        .sheet(isPresented: $showAddProfile) {
            AddProfileView { newProfile in
                GitService.switchTo(profile: newProfile)
                current = GitService.readCurrentProfile()
                profiles = GitService.extractAllGitProfiles()
            }
        }
    }
}

#Preview {
    ContentView()
}

