## Context

Issue #43 asks for a rationalized desktop setup model for macOS 26 on Apple Silicon with no Touch Bar support. The current repo has three overlapping patterns:

- full-file sync from `Library/**` into `~/Library/**`
- reverse copy-back from the machine into the repo
- imperative macOS writes through `defaults`, `pmset`, `scutil`, and `PlistBuddy`

That overlap creates three concrete problems:

- export only refreshes many files that are already tracked, so new Xcode or app files created on the main machine can be missed
- the Dock is managed both as a full plist copy and as explicit writes, even though the tracked plist contains historical machine-specific metadata
- app orchestration depends on `ls /Applications | grep ...`, and some current flows mutate prefs without clearly separating first launch, quit, and apply

Constraints and user decisions:

- target only macOS 26 on Apple Silicon
- keep Mission Control and hot corners working as currently intended
- keep macOS keyboard shortcut sync through `com.apple.symbolichotkeys.plist`
- treat the main machine as the source for export, then replay that state on another machine
- allow a first launch for apps that need to create their support files before repo-managed prefs are applied
- remove Sublime Text 3, Transmission, Touch Bar prefs, VS Code sync, and Dashboard-era behavior

Current references informing this design:

- `man defaults` warns against mutating defaults for running applications
- `man scutil` documents stable `ComputerName`, `HostName`, and `LocalHostName` writes
- `man pmset` documents current Apple Silicon power settings surface
- Apple Support: Desktop & Dock settings on Mac (macOS 26)
- Apple Support: Use hot corners on Mac (macOS 26)
- Apple Support: Change Trackpad settings on Mac (macOS 26)
- Apple Support: Change your computer’s name or local hostname on Mac
- Rectangle README documenting plist-backed prefs and JSON import/export
- dockutil README and Homebrew formula availability

## Goals / Non-Goals

**Goals:**

- Replace tracked-file-based export with managed-root-based export for retained desktop state
- Keep selected app-owned state portable across machines, including symbolic hotkeys and Xcode user data
- Make apply flows safe for apps that need a bootstrap launch before their prefs exist
- Replace Dock plist sync with a canonical manifest plus convergent Dock rebuilds
- Keep macOS defaults explicit, reviewable, and valid for macOS 26
- Remove retired or unsupported config surfaces from both tracked state and scripts

**Non-Goals:**

- Supporting Intel Macs, older macOS releases, or Touch Bar machines
- Preserving historical settings for removed apps
- Designing a generic bidirectional sync engine for arbitrary Library paths
- Introducing new desktop state beyond the surfaces already deemed worth keeping

## Decisions

### 1. Desktop preference sync becomes managed-root-based instead of tracked-file-based

The repo will define explicit managed roots for retained desktop state and treat those roots as the sync contract. Export will mirror machine state from those roots into the repo, which allows newly created files to be discovered and versioned. Apply will mirror repo state back into those same roots.

Why this over the current tracked-file iteration:

- it fixes the Xcode drift problem where new files are created on the main machine but never copied back because the repo did not already know about them
- it makes source-of-truth boundaries explicit per root instead of implicit per pre-existing file
- it preserves reviewability because the set of managed roots remains small and deliberate

Alternatives considered:

- **Keep tracked-file-based export**: rejected because it cannot discover new files under retained roots
- **Sync all of `~/Library`**: rejected because it would pull too much machine-specific and low-value state

Initial managed roots should include retained app/system-owned artifacts such as `com.apple.symbolichotkeys.plist`, selected app preference plists, `Library/Developer/Xcode/UserData/`, `Library/Colors/`, `Library/Services/`, and `Library/Spelling/LocalDictionary`.

### 2. App apply flow explicitly supports bootstrap launch, quit, then sync

For apps whose prefs or support directories do not exist until first launch, apply will allow a one-time bootstrap launch, wait for the app to materialize its files, then quit the app before copying repo-managed state.

Why this over a pure “never launch apps” rule:

- several macOS apps create required preference containers only after first launch
- the user explicitly wants installs to become fully usable without manual preference imports
- this still follows `man defaults` guidance because the actual mutation happens after the app is no longer running

Alternatives considered:

- **Never launch apps during apply**: rejected because some preference roots would not exist on a fresh install
- **Keep apps open while syncing**: rejected because running apps may overwrite or ignore changed defaults

App presence detection should move away from `ls /Applications | grep ...` toward LaunchServices-aware checks such as app names or bundle identifiers resolved by system tools.

### 3. Dock layout becomes an explicit manifest applied with dockutil

The repo will stop syncing `Library/Preferences/com.apple.dock.plist` as desktop state. Instead, it will store a canonical Dock manifest in the repo and use `dockutil` to export the current layout from the main machine and apply that layout convergently elsewhere.

Why this over plist sync:

- the current Dock plist contains GUIDs, timestamps, stale app references, and other machine-specific metadata
- the user wants identical Docks across machines, which is better expressed as a canonical layout than as opaque plist replication
- `dockutil` is purpose-built for listing, removing, and adding Dock items and is available from Homebrew

Alternatives considered:

- **Keep full Dock plist sync**: rejected because it encodes historical and machine-specific state instead of clear intent
- **Hand-build Dock plist payloads with `defaults`**: rejected because the resulting data is harder to review and maintain than a manifest plus `dockutil`

The canonical layout should rebuild only the managed non-implicit items. Finder and Trash remain implicit system Dock items. Brave and iTerm remain conditional: include them when installed, skip them otherwise.

### 4. macOS defaults remain explicit and separate from exported app state

`scripts/macos.sh` should continue to use explicit `defaults`, `pmset`, `scutil`, and targeted plist edits for macOS-owned settings that are still valid on macOS 26. It should not rely on full Apple plist sync except where the state is intentionally opaque and user-valued, namely `com.apple.symbolichotkeys.plist`.

Why this split:

- Apple’s current settings docs expose Dock behavior, hot corners, Mission Control, and trackpad behavior as explicit supported settings
- explicit writes are easier to review and keep current than opaque plist copies
- symbolic hotkeys are the exception because the user wants their custom Keyboard Shortcuts settings synced and the stored format is already an opaque system-owned map

Alternatives considered:

- **Sync more Apple plists wholesale**: rejected because it mixes desired settings with stale metadata and historical drift
- **Recreate symbolic hotkeys with individual defaults writes**: rejected because the current stored structure is opaque and the user explicitly values the exported state

### 5. Machine naming stays in macOS setup but becomes stable and convergent

The repo will keep setting `ComputerName`, `HostName`, `LocalHostName`, and `NetBIOSName` through the explicit machine-name input already required by bootstrap, but it will set the provided name exactly and stop appending the current date.

Why this over inventing a new first-run state tracker:

- the user already provides the intended machine name during setup
- removing the date suffix restores convergence without introducing additional state machinery
- repeated runs setting the same explicit name are harmless and predictable

Alternatives considered:

- **Append a date or unique suffix**: rejected because it breaks convergence
- **Add a separate “first-run only” sentinel file**: rejected as unnecessary complexity for the desired behavior

### 6. Retired surfaces are removed from both tracked artifacts and script logic

The change will remove Sublime Text 3, Transmission, Touch Bar prefs, VS Code sync/orchestration, and Dashboard-era writes from the managed surface.

Why this is a design decision and not just cleanup:

- the sync/export model depends on a clear inventory of what belongs in the repo
- carrying removed apps forward would keep the managed-root contract ambiguous

## Risks / Trade-offs

- **[Managed-root export may pull new noisy files after app upgrades]** → Keep the managed root list explicit and review new files in git before committing
- **[Bootstrap launch timing may vary between apps]** → Limit launch-once behavior to specific managed apps that need it and keep quit/apply sequencing explicit
- **[dockutil behavior may differ on future macOS releases]** → Scope the change to macOS 26 and verify Dock export/apply in repo validation before relying on it broadly
- **[Keeping symbolic hotkeys as a full-file sync preserves an opaque format]** → Accept the opacity because the user actively relies on these settings and the file is the most faithful export surface
- **[Pruning retired state could remove something still needed]** → Keep the removal list explicit in the change and validate retained apps after the first export/apply pass

## Migration Plan

1. Define the retained managed roots and remove retired tracked artifacts from `Library/**`
2. Introduce managed-root export/apply logic, including app bootstrap-launch support where required
3. Add canonical Dock manifest export/apply via `dockutil` and stop syncing `com.apple.dock.plist`
4. Modernize `scripts/macos.sh` for macOS 26 and remove legacy Dashboard/Touch Bar behavior
5. Run export from the main machine, review the resulting repo state, then apply on the secondary machine to verify convergence

## Open Questions

- Which newly discovered files under retained roots need exclusions after the first export pass, especially under Xcode user data
