#!/bin/bash

# Claude Code Safety Check Script
# This script intercepts bash commands and blocks potentially dangerous operations
# Based on the deny list patterns in ~/.claude/settings.json

COMMAND="$1"

# Read deny patterns from settings.json
DENY_PATTERNS=(
  "git config --global"
  "brew install"
  "brew upgrade"
  "brew uninstall"
  "sudo"
  "chmod 777"
  "chmod +x /"
  "rm -rf /"
  "rm -rf ~/"
  "rm -rf ."
  "rm -rf .."
  "> /dev/sda"
  "dd if=/dev/zero of=/dev/"
  "mkfs."
  "gh repo delete"
  "gh auth logout"
  "npm install -g"
  "pip install"
  "gem install"
  "curl .* | bash"
  "wget .* | bash"
  "systemctl"
  "service"
  "killall"
  "kill -9"
  "shutdown"
  "reboot"
  "poweroff"
)

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if command matches any deny pattern
is_denied() {
  local cmd="$1"
  for pattern in "${DENY_PATTERNS[@]}"; do
    if [[ "$cmd" =~ $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# Main check
if is_denied "$COMMAND"; then
  echo -e "${RED}❌ BLOCKED: This command matches a deny pattern${NC}"
  echo -e "${YELLOW}Command: $COMMAND${NC}"
  echo -e "${YELLOW}Reason: This command could potentially harm your system or modify critical configurations${NC}"
  echo ""
  echo -e "${GREEN}Suggestions:${NC}"
  echo "• If you need to install packages, do it manually"
  echo "• For system changes, review and execute commands yourself"
  echo "• Use --dangerously-skip-permissions flag only when necessary"
  exit 1
fi

# Command is allowed
exit 0
