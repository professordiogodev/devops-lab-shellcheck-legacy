#!/usr/bin/env bash
# Run with: ./verify.sh
set -uo pipefail
cd "$(dirname "$0")"; ROOT=$(pwd)
command -v shellcheck >/dev/null || { echo "Install shellcheck: sudo apt install shellcheck"; exit 1; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT

echo "== shellcheck is happy =="
for s in backup cleanup rotate health; do
  check "scripts/$s.sh: zero findings (shellcheck, all severities)" shellcheck -S style "scripts/$s.sh"
done
check "every script has a proper shebang (env bash or bash)" bash -c "for f in scripts/*.sh; do head -1 \$f | grep -qE '^#!.*bash' || exit 1; done"

echo "== backup.sh behaves =="
mkdir -p "$W/src" "$W/dest dir"
echo 1 > "$W/src/plain.txt"; echo 2 > "$W/src/my file.txt"; echo 3 > "$W/src/-odd.txt"
check "copies files, including names with spaces, to a destination with a space" bash -c "'$ROOT/scripts/backup.sh' '$W/src' '$W/dest dir' >/dev/null 2>&1; [ -f '$W/dest dir/my file.txt.bak' ] && [ -f '$W/dest dir/plain.txt.bak' ]"
check "reports the right number of files"                   bash -c "'$ROOT/scripts/backup.sh' '$W/src' '$W/dest dir' 2>&1 | grep -q '3'"
check "no arguments: usage message and non-zero exit"       bash -c "'$ROOT/scripts/backup.sh' >/dev/null 2>&1; [ \$? -ne 0 ]"

echo "== cleanup.sh is safe =="
mkdir -p "$W/data/cache" "$W/data/precious"; echo x > "$W/data/cache/a"; echo "my file" > "$W/data/cache/b c"; echo keep > "$W/data/precious/keepme"
check "empties the cache folder, files with spaces included" bash -c "DATA_DIR='$W/data' '$ROOT/scripts/cleanup.sh' cache >/dev/null 2>&1; [ -z \"\$(ls -A '$W/data/cache')\" ]"
check "empty argument: refuses and exits non-zero"          bash -c "DATA_DIR='$W/data' '$ROOT/scripts/cleanup.sh' '' >/dev/null 2>&1; [ \$? -ne 0 ]"
check "...and the sibling folder survived the bad call"     test -f "$W/data/precious/keepme"
check "unset DATA_DIR: refuses and exits non-zero"          bash -c "env -u DATA_DIR '$ROOT/scripts/cleanup.sh' cache >/dev/null 2>&1; [ \$? -ne 0 ]"

echo "== rotate.sh behaves =="
mkdir -p "$W/my logs"; for i in 1 2 3 4 5; do echo $i > "$W/my logs/app$i.log"; touch -d "2026-01-0$i" "$W/my logs/app$i.log"; done
check "keeps the newest 3 logs in a folder with a space"    bash -c "'$ROOT/scripts/rotate.sh' '$W/my logs' >/dev/null 2>&1; [ \$(ls '$W/my logs'/*.log | wc -l) = 3 ] && [ -f '$W/my logs/app5.log' ] && [ ! -f '$W/my logs/app1.log' ]"
mkdir -p "$W/empty"
check "an empty folder does not crash it"                   bash -c "'$ROOT/scripts/rotate.sh' '$W/empty' >/dev/null 2>&1"
check "a missing folder: error and non-zero (no rm in the wrong place)" bash -c "cd '$W' && mkdir -p other && touch other/x.log && cd other && '$ROOT/scripts/rotate.sh' '$W/nonexistent' >/dev/null 2>&1; r=\$?; [ \$r -ne 0 ] && [ -f '$W/other/x.log' ]"

echo "== health.sh behaves =="
check "a dead URL fails with exit 1 after retrying"         bash -c "'$ROOT/scripts/health.sh' http://127.0.0.1:9 1 >/dev/null 2>&1; [ \$? = 1 ]"
check "no arguments: usage and non-zero exit"               bash -c "'$ROOT/scripts/health.sh' >/dev/null 2>&1; [ \$? -ne 0 ]"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$pass)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
