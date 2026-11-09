#!/usr/bin/env bash
# Checks your tools. Run with: ./setup.sh
if ! command -v shellcheck >/dev/null; then echo "Install shellcheck first:  sudo apt install shellcheck"; exit 1; fi
echo "shellcheck $(shellcheck --version | sed -n 's/^version: //p') is installed."
echo "The legacy scripts are in scripts/. Start with:  shellcheck scripts/*.sh"
