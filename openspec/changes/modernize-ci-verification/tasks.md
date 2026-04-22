## 1. Update action versions in the lint job

- [ ] 1.1 Update `actions/checkout` to `v6` in the `lint_content` job
- [ ] 1.2 Update `jdx/mise-action` to `v4` in the `lint_content` job

## 2. Replace bootstrap jobs with a single validation job

- [ ] 2.1 Remove the `bootstrap_all_dry_run` job
- [ ] 2.2 Remove the `bootstrap_quick` job
- [ ] 2.3 Remove the `bootstrap_all` job
- [ ] 2.4 Remove the `bootstrap_rsync_back` job
- [ ] 2.5 Add a `validate_bootstrap` job using `actions/checkout@v6` and `jdx/mise-action@v4` that runs `zsh scripts/validate_bootstrap.sh`

## 3. Verify

- [ ] 3.1 Push the updated workflow and confirm both CI jobs (`lint_content` and `validate_bootstrap`) pass
