#!/bin/bash

# Extracts org/repo from git remote (e.g., org/repo → org-repo), falls back to directory name
result=$(git remote get-url origin 2>/dev/null | tr ':' '/' | rev | cut -d/ -f1-2 | rev | tr '/' '-' | sed 's/\.git$//') && [ -n "$result" ] && echo "$result" || basename "$PWD"
