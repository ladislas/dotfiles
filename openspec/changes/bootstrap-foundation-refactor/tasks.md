## 1. Bootstrap runtime cleanup

- [x] 1.1 Replace regex-based argument detection with an explicit parser that handles supported flags and `--computer_name=<value>` without external grep utilities
- [x] 1.2 Validate aggregate modes and required flag combinations before stateful bootstrap work begins
- [x] 1.3 Make dry-run, redirected-home sandboxing, and runtime setup behavior explicit, including brew prefix detection and prerequisite checks

## 2. Failure and helper semantics

- [ ] 2.1 Refactor command execution helpers to distinguish fatal versus recoverable operations with transparent command attribution
- [ ] 2.2 Update shared helper functions to remove implicit regex-based argument checks and align with the documented runtime contract
- [ ] 2.3 Document the bootstrap runtime contract for sourced domain scripts, including environment, sudo expectations, logging, and dry-run behavior

## 3. Rerun safety and verification

- [ ] 3.1 Introduce a shared rerun-safe linking helper and update bootstrap-managed symlink operations to use it
- [ ] 3.2 Update affected domain scripts such as `scripts/dev.sh` to use the rerun-safe linking behavior where bootstrap manages links
- [ ] 3.3 Add redirected-home validation coverage for user-scoped bootstrap flows and clearly reject or skip unsupported system-scoped domains in sandbox mode
- [ ] 3.4 Verify the refactor with representative dry-run, invalid-input, fatal-failure, recoverable-failure, redirected-home, and rerun-safe link scenarios
