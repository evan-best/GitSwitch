# GitSwitch

**Easily switch between Git profiles on macOS.**  
GitSwitch is a native Swift menu bar app that helps developers manage multiple Git identities for work, school, and personal use — without touching the terminal.

---

## ✨ Features

- 🧠 **Profile Management**  
  Add, edit, and delete Git profiles with name, email, and SSH key.

- 🔐 **Secure Key Storage**  
  Profiles are encrypted and stored securely using macOS Keychain.

- 💻 **Quick Switching**  
  Instantly apply a selected Git profile globally or per repository.

- 🔑 **SSH Key Viewer**  
  View and copy the associated public SSH key for any profile.

- 🧹 **Safe Deletes**  
  Prevent mistakes with confirmation prompts before deleting profiles.

- 🍏 **Native macOS UI**  
  Lightweight menu bar utility built with Swift and SwiftUI.

---

## 🛠️ Setup

### Requirements

- macOS 12+
- Xcode 14+
- Swift 5.7+

### Clone & Build

```bash
git clone https://github.com/evan-best/GitSwitch.git
cd GitSwitch
open GitSwitch.xcodeproj
```

Build and run the app from Xcode with ⌘ + R.

---

## 🚀 Usage

1. Launch GitSwitch from your menu bar.
2. Click **Add Profile** to create a Git profile with name, email, and SSH key.
3. Click a profile to activate it (updates `git config --global`).
4. Click a profile for details — copy the public SSH key when needed.
5. Use the **delete** button with care — you'll get a confirmation prompt.

---

## 🔐 Security

GitSwitch uses the **macOS Keychain** to securely store profile credentials.  
No sensitive data is stored in plain text or transmitted outside your device.

---

## 📦 Roadmap

Planned future updates include:

- 🔄 Repo-specific profile switching

---

## 🧪 Known Limitations

- SSH key switching affects global config; per-repo overrides must be handled manually (for now).
- Only supports OpenSSH key format.

---

## 🙌 Contributing

PRs and issues are welcome!  
If you'd like to contribute:

1. Fork the repo
2. Create a feature branch
3. Submit a PR with clear, documented changes

Please open an issue first for large features.

---

## 📄 License

GitSwitch is licensed under the MIT License.  
See the [LICENSE](LICENSE) file for more details.

---

## 💡 Why GitSwitch?

Switching between Git identities across work and personal projects is tedious and error-prone.  
GitSwitch was built to remove that friction with a fast, secure, and native experience.

---

## 🧑‍💻 Author

Created by [Evan Best](https://github.com/evan-best)
