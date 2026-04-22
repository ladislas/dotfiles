## ADDED Requirements

### Requirement: macOS setup applies explicit macOS 26 defaults

The macOS setup flow SHALL configure supported macOS 26 desktop preferences through explicit settings writes instead of relying on full Apple desktop plist sync.

#### Scenario: Rerun converges explicit settings without plist replication

- **WHEN** the macOS setup flow is run repeatedly on the same machine with the same intended settings
- **THEN** the resulting managed desktop preference state converges without depending on a copied `com.apple.dock.plist`

### Requirement: Hot corners and Mission Control behavior remain configured

The macOS setup flow SHALL continue to configure the user’s desired hot corners and related Mission Control behavior.

#### Scenario: Hot corner mapping is preserved

- **WHEN** the macOS setup flow is applied
- **THEN** the top-left corner is configured for Mission Control, the top-right corner for application windows, and both bottom corners for Desktop

### Requirement: Machine naming is stable and convergent

The macOS setup flow SHALL set the provided machine name exactly for the system naming surfaces it manages and SHALL NOT append the current date or another non-deterministic suffix.

#### Scenario: Applying macOS setup uses the explicit provided machine name

- **WHEN** bootstrap runs macOS setup with `--computer_name=<value>`
- **THEN** `ComputerName`, `HostName`, `LocalHostName`, and `NetBIOSName` are set to the provided value without an added date suffix

### Requirement: Legacy or unsupported macOS desktop tweaks are removed from the managed surface

The macOS setup flow SHALL stop writing legacy settings that are outside the supported macOS 26 Apple Silicon desktop surface.

#### Scenario: Dashboard and Touch Bar settings are no longer mutated

- **WHEN** the macOS setup flow runs on a supported machine
- **THEN** it does not attempt to write Dashboard settings or Touch Bar preference settings
