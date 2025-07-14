//
//  ContentView.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import SwiftUI

struct ContentView: View {
    @State private var current: CurrentGitConfig = GitService.readCurrentProfile()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(current.name.isEmpty ? "No Git user found" : current.name)
                        .font(.headline)

                    if !current.email.isEmpty {
                        Text(current.email)
                            .bold()
                            .font(.subheadline)
                    } else {
                        Text("No email configured")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }

            if let ssh = current.sshKeyPath {
                Text("SSH Key: \(ssh)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            Button("Add Profile…") {
                print("TODO: Open add profile UI")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 260)
    }
}



#Preview {
    ContentView()
}
