#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
log-explorer — quick pipelines for exploring logs

Usage:
  $(basename "$0") --page FILE
  $(basename "$0") --grep PATTERN FILE
  $(basename "$0") --count PATTERN FILE
  $(basename "$0") --recent PATTERN FILE [N]
  $(basename "$0") --report FILE OUT.txt
  $(basename "$0") --help
USAGE
}

page_file()      { less "$1"; }
grep_page()      { grep -i -- "$1" "$2" | less; }
count_matches()  { grep -i -- "$1" "$2" | wc -l; }
recent_matches() { grep -i -- "$1" "$2" | tail -n "${3:-50}"; }
make_report() {
  { echo "=== Log Report for $1 ==="; date; echo;
    echo "--- Top 20 'error' lines ---";   grep -i error "$1" | head -n 20; echo;
    echo "--- Top 20 'warning' lines ---"; grep -i warning "$1" | head -n 20;
  } > "$2"
  echo "Wrote $2"
}

cmd="${1:-}"; [[ -z "$cmd" ]] && { usage; exit 1; }
shift || true
case "$cmd" in
  --page)   [[ $# -ge 1 ]] || { usage; exit 1; }; page_file "$1" ;;
  --grep)   [[ $# -ge 2 ]] || { usage; exit 1; }; grep_page "$1" "$2" ;;
  --count)  [[ $# -ge 2 ]] || { usage; exit 1; }; count_matches "$1" "$2" ;;
  --recent) [[ $# -ge 2 ]] || { usage; exit 1; }; recent_matches "$1" "$2" "${3:-}" ;;
  --report) [[ $# -ge 2 ]] || { usage; exit 1; }; make_report "$1" "$2" ;;
  --help|-h) usage ;;
  *) usage; exit 1 ;;
esac
