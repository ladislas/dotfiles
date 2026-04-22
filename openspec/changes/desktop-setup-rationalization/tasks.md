## 1. Prune and redefine the managed desktop state surface

- [x] 1.1 Remove retired tracked artifacts and script references for Sublime Text 3, Transmission, Touch Bar preferences, Visual Studio Code sync, and Dock plist sync
- [x] 1.2 Define the retained managed desktop roots for app-owned state, symbolic hotkeys, Xcode user data, spelling, colors, and Services
- [x] 1.3 Run an initial export from the main machine to identify newly discovered files under retained roots and decide any needed exclusions

## 2. Rebuild desktop state export/apply around managed roots

- [x] 2.1 Replace tracked-file-based export logic with managed-root-based export that can add new files under retained roots
- [x] 2.2 Update apply logic to bootstrap-launch managed apps when needed, quit them before sync, and use robust app detection instead of `ls /Applications | grep`
- [x] 2.3 Add retained Rectangle plist sync and ensure `com.apple.symbolichotkeys.plist` remains part of export/apply

## 3. Replace Dock plist sync with canonical Dock management

- [ ] 3.1 Add `dockutil` to the managed app/tooling flow and define the repository Dock manifest format
- [ ] 3.2 Implement Dock export from the current machine into the canonical manifest
- [ ] 3.3 Implement convergent Dock apply for the desired baseline and conditional Brave/iTerm items

## 4. Modernize macOS 26 defaults automation

- [ ] 4.1 Remove Dashboard-era and Touch Bar-era macOS writes and keep only supported explicit macOS 26 settings
- [ ] 4.2 Preserve the desired hot corners and Mission Control behavior through explicit macOS settings writes
- [ ] 4.3 Make machine naming stable by applying the provided name exactly without appending a date suffix

## 5. Validate and document the new workflow

- [ ] 5.1 Verify export from the main machine captures newly created retained files such as Xcode user data changes
- [ ] 5.2 Verify apply on another macOS 26 machine converges desktop state and Dock layout on rerun
- [ ] 5.3 Update repo guidance so the export-from-main / apply-on-other-machine workflow and source-of-truth rules are explicit
