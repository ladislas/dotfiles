## 1. Plan and scaffold the workflow

- [ ] 1.1 Create OpenSpec change artifacts that define the repo-local tooling baseline and its requirements
- [ ] 1.2 Initialize the repository OpenSpec/opencode scaffold and add project-local guidance needed for future changes

## 2. Add repo-local lint and hook tooling

- [ ] 2.1 Add pinned `mise` config and lint tasks for Markdown and YAML files
- [ ] 2.2 Add `hk` pre-commit configuration and hook installation task
- [ ] 2.3 Add Markdown and YAML lint configuration, including OpenSpec and opencode overrides copied from the working `mypac` setup

## 3. Document and verify the workflow

- [ ] 3.1 Update repository docs to explain tool installation, hooks, and lint commands
- [ ] 3.2 Update CI to install the repo-local toolchain and run the lint workflow
- [ ] 3.3 Run the lint tasks and relevant bootstrap checks to verify the new baseline
