## ADDED Requirements

### Requirement: Dock layout is stored as a canonical manifest

The desktop setup system SHALL store the managed Dock layout as a canonical repository manifest rather than syncing `com.apple.dock.plist`.

#### Scenario: Export updates Dock manifest instead of Dock plist

- **WHEN** the user exports the current Dock layout from the main machine
- **THEN** the repository updates the canonical Dock manifest and does not treat `Library/Preferences/com.apple.dock.plist` as the source of truth

### Requirement: Dock apply converges managed non-implicit items

The Dock apply flow SHALL rebuild the managed non-implicit Dock items in canonical order on every rerun.

#### Scenario: Apply restores the canonical Dock lineup on another machine

- **WHEN** a second machine applies the repository Dock configuration
- **THEN** the Dock is rebuilt to match the canonical manifest order for managed items while preserving the system-provided Finder and Trash items

#### Scenario: Local Dock drift is overwritten on rerun

- **WHEN** a machine’s managed Dock items have been manually rearranged or changed
- **THEN** the next Dock apply run restores the canonical manifest-defined layout

### Requirement: Conditional app Dock items depend on installation state

The Dock apply flow SHALL add optional app items only when the corresponding applications are installed.

#### Scenario: Optional app is installed

- **WHEN** Brave Browser or iTerm is installed on the machine during Dock apply
- **THEN** the canonical Dock rebuild includes that app in its configured position

#### Scenario: Optional app is not installed

- **WHEN** Brave Browser or iTerm is not installed on the machine during Dock apply
- **THEN** the Dock rebuild skips that app and still completes successfully

### Requirement: Canonical Dock baseline includes the desired persistent folders

The Dock manifest SHALL encode the user’s desired baseline folders for the “others” side of the Dock.

#### Scenario: Apply restores Applications and Downloads folders

- **WHEN** the canonical Dock configuration is applied
- **THEN** the resulting Dock includes the Applications folder and the user’s Downloads folder in the configured “others” section order
