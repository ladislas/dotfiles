#!/usr/bin/env bash
#MISE description="Lint YAML files"
set -euo pipefail

files=()
while IFS= read -r line; do
  files+=("$line")
done < <(git ls-files '*.yml' '*.yaml')
existing_files=()

for file in "${files[@]}"; do
  if [[ -f "$file" ]]; then
    existing_files+=("$file")
  fi
done

if ((${#existing_files[@]} == 0)); then
  exit 0
fi

yamllint -c .yamllint.yaml "${existing_files[@]}"
