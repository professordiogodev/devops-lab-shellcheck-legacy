#!/usr/bin/env bash
rc=0
if command -v shellcheck >/dev/null; then
  if shellcheck -S style scripts/*.sh >/dev/null 2>&1; then echo "- ✅ shellcheck reports nothing on the four scripts"; else echo "- ❌ shellcheck still reports findings on scripts/*.sh"; rc=1; fi
else echo "- ⚠️ shellcheck is not installed on the runner, skipped"; fi
if grep -rq 'shellcheck disable' scripts/; then echo "- ❌ 'shellcheck disable' comments found: fix the code instead of hiding the warning"; rc=1; else echo "- ✅ no shellcheck disable comments"; fi
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
exit $rc
