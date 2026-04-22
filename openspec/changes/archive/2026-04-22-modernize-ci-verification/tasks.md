## 1. Update action versions in the lint job

- [x] 1.1 Update `actions/checkout` to `v6` in the `lint_content` job
- [x] 1.2 Update `jdx/mise-action` to `v4` in the `lint_content` job

## 2. Replace bootstrap jobs with a single validation job

- [x] 2.1 Remove the `bootstrap_all_dry_run` job
- [x] 2.2 Remove the `bootstrap_quick` job
- [x] 2.3 Remove the `bootstrap_all` job
- [x] 2.4 Remove the `bootstrap_rsync_back` job
- [x] 2.5 Add a `validate_bootstrap` job using `actions/checkout@v6` and `jdx/mise-action@v4` that runs `zsh scripts/validate_bootstrap.sh`

## 3. Verify

- [x] 3.1 Push the updated workflow and confirm both CI jobs (`lint_content` and `validate_bootstrap`) pass
