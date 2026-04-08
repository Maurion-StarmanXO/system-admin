#!/usr/bin/env bash
# sys_audit.sh — minimal

set -u  # error if we use an unset variable (helps catch typos)

echo "== System Info =="
echo "Host: $(hostname)"
echo "User: $USER"
echo "Date: $(date)"

if [[ "${1-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./sys_audit.sh [TARGET_DIR]

Runs a quick system audit and creates a compressed backup of TARGET_DIR
(defaults to $HOME). Backup errors append to sys_audit.log.
EOF
  exit 0
fi

echo
echo "== Disk Usage (root filesystem) =="
df -h /

echo
echo "== Top 5 processes by CPU =="
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

echo
echo "== Backup =="
TARGET_DIR="${1:-$HOME}"                             # use arg1 or default to $HOME
BACKUP_NAME="backup-$(date +%F-%H%M%S).tar.gz"       # e.g., backup-2025-10-05-142530.tar.gz
LOG_FILE="sys_audit.log"

echo "Backing up: $TARGET_DIR"
tar -czf "$BACKUP_NAME" "$TARGET_DIR" 1>>"$LOG_FILE" 2>&1 \
  && echo "Backup created: $BACKUP_NAME" \
  || echo "Backup failed (see $LOG_FILE)"

echo
echo "== Files in target not owned by $USER (first 10) =="
find "$TARGET_DIR" -xdev -type f -not -user "$USER" 2>/dev/null | head -n 10

echo
echo "== World-writable files in target (first 10) =="
# -perm -0002 means “other writable” bit is set (risky on multi-user systems)
find "$TARGET_DIR" -xdev -type f -perm -0002 2>/dev/null | head -n 10
