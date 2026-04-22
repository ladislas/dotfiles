## Why

The repository still mixes historical app preference copies, full Apple plist sync, and imperative macOS defaults writes in ways that are hard to reason about on macOS 26. Export also depends too much on files that are already tracked, which means new Xcode or app settings created on the main machine can drift out of sync instead of being captured back into the repo.

## What Changes

- Replace tracked-file-based desktop preference export with managed-root-based export so new files created under retained config roots can be pulled back into the repo
- Keep selected app-owned and user-owned state under version control, including macOS keyboard shortcuts (`com.apple.symbolichotkeys.plist`), Rectangle preferences, Xcode user data, spelling, colors, and Services workflows
- Modernize app preference apply flow so apps may be launched once to create their support files, then quit before repo-managed state is copied into place
- Replace full `com.apple.dock.plist` sync with an explicit canonical Dock manifest that can be exported from the main machine and convergently applied on other machines
- Add `dockutil` as the Dock layout dependency and stop treating the Dock plist as the source of truth
- Modernize `scripts/macos.sh` for macOS 26 by keeping explicit supported defaults, preserving hot corners and Mission Control behavior, removing Dashboard-era and Touch Bar-era settings, and making machine naming stable instead of date-appended
- Remove retired sync targets and orchestration for Sublime Text 3, Touch Bar preferences, Transmission preferences, and Visual Studio Code preference sync

## Capabilities

### New Capabilities

- `desktop-state-sync`: Export and apply explicitly managed desktop preference roots so new settings created on the main machine can be captured and replayed on another machine
- `dock-layout-management`: Export and apply a canonical Dock layout through an explicit manifest instead of syncing `com.apple.dock.plist`
- `macos-setup-convergence`: Apply macOS 26 desktop defaults through explicit, rerun-safe automation that preserves desired hot corners, Mission Control behavior, and stable machine naming

### Modified Capabilities
<!-- No existing spec-level capabilities are changing. -->

## Impact

- `scripts/apps.sh`, `scripts/apps_config.sh`, `scripts/rsync_config.sh`, `scripts/macos.sh`, and possibly `bootstrap.sh`
- `Library/**` tracked preference artifacts, especially retired state and retained managed roots
- New canonical Dock manifest under `config/` and new `dockutil` dependency in the app install flow
- Desktop setup documentation and source-of-truth guidance for export/apply workflows
