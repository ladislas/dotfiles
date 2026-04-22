## ADDED Requirements

### Requirement: Desktop state sync uses explicit managed roots

The desktop state sync system SHALL define an explicit set of repo-managed roots for retained desktop state instead of deriving sync scope from files that are already tracked in the repository.

#### Scenario: Export discovers a new Xcode file under a managed root

- **WHEN** the main machine creates a new file under a managed root such as `~/Library/Developer/Xcode/UserData/`
- **THEN** the export flow copies that file into the corresponding repository path even if the file was not previously tracked

#### Scenario: Export reflects deletions inside a managed root

- **WHEN** a previously managed file is removed from the main machine inside a managed root
- **THEN** the next export updates the repository copy so the managed root reflects the machine’s current state

### Requirement: Apply supports bootstrap launch before syncing app-owned state

The apply flow SHALL allow managed apps to be launched once to create their preference or support files, then quit those apps before repo-managed state is copied into place.

#### Scenario: Fresh install of a managed app has no existing preference files

- **WHEN** a managed app is installed on a fresh machine and its preference root does not yet exist
- **THEN** the apply flow launches the app once, waits for its files to be created, quits the app, and only then applies the repository state

#### Scenario: Running app is not mutated in place

- **WHEN** a managed app is already running when desktop state apply begins
- **THEN** the apply flow quits the app before writing managed preference files for that app

### Requirement: Keyboard shortcut state remains part of managed desktop sync

The desktop state sync system SHALL export and apply the macOS keyboard shortcut state stored in `com.apple.symbolichotkeys.plist`.

#### Scenario: Export captures keyboard shortcut changes from System Settings

- **WHEN** the user changes a keyboard shortcut in System Settings and runs desktop state export
- **THEN** the repository copy of `Library/Preferences/com.apple.symbolichotkeys.plist` is updated to match the machine

#### Scenario: Apply restores keyboard shortcut state on another machine

- **WHEN** another macOS 26 machine applies the repository desktop state
- **THEN** the managed symbolic hotkeys file is copied into place as part of the apply flow

### Requirement: Retired desktop sync targets are excluded from managed state

The desktop state sync system SHALL stop exporting and applying retired targets that are no longer part of the supported desktop setup surface.

#### Scenario: Removed app targets are not exported or applied

- **WHEN** desktop state export or apply runs after this change
- **THEN** Sublime Text 3, Transmission, Touch Bar preferences, and Visual Studio Code preference sync are excluded from the managed desktop state surface

### Requirement: Rectangle preferences are managed through the app plist surface

The desktop state sync system SHALL treat Rectangle preferences as an app-owned plist-backed managed root so they can be exported automatically from the main machine and applied on another machine.

#### Scenario: Rectangle preference changes are captured without manual JSON export

- **WHEN** the user changes Rectangle settings on the main machine and runs desktop state export
- **THEN** the repository updates the managed Rectangle preference plist without requiring a manual in-app JSON export step
