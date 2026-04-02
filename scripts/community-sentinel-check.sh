#!/usr/bin/env bash
# Hermetic Community Sentinel — 7 Contamination Gates
# Compares current default build against frozen baseline in .ci/community-baseline.json
# All measurements use: cargo build --release / cargo run --release (NO feature flags)
# Exit 0 = PASS, Exit 1 = FAIL
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

BASELINE=".ci/community-baseline.json"
if [ ! -f "$BASELINE" ]; then
    echo "ERROR: Baseline file $BASELINE not found. Run community-baseline.sh first."
    exit 1
fi

echo "══════════════════════════════════════════════════"
echo "  HERMETIC COMMUNITY SENTINEL"
echo "══════════════════════════════════════════════════"
echo ""

# Read baseline values
B_DEP=$(python3 -c "import json; print(json.load(open('$BASELINE'))['dep_count'])")
B_TEST=$(python3 -c "import json; print(json.load(open('$BASELINE'))['test_count'])")
B_CFG=$(python3 -c "import json; print(json.load(open('$BASELINE'))['cfg_count'])")
B_TMPL=$(python3 -c "import json; print(json.load(open('$BASELINE'))['template_count'])")
B_CMD=$(python3 -c "import json; print(json.load(open('$BASELINE'))['cmd_count'])")
B_SIZE=$(python3 -c "import json; print(json.load(open('$BASELINE'))['bin_size'])")

# Build Community profile
echo "Building Community profile (default features)..."
cargo build --release 2>&1 | tail -3
echo ""

FAILED=0

# S-1: Dependency count (exact — 0 new deps)
C_DEP=$(cargo tree --edges=normal 2>/dev/null | wc -l)
if [ "$C_DEP" -le "$B_DEP" ]; then
    echo "  S-1 PASS  dep_count: $C_DEP (baseline: $B_DEP)"
else
    echo "  S-1 FAIL  dep_count: $C_DEP > baseline: $B_DEP"
    FAILED=1
fi

# S-2: Build pass
if cargo build --release 2>&1 | grep -q 'error\['; then
    echo "  S-2 FAIL  build errors detected"
    FAILED=1
else
    echo "  S-2 PASS  build clean"
fi

# S-3: Test count (>= baseline, shrinkage blocked)
C_TEST=$(cargo test --release -- --list 2>&1 | grep ': test$' | wc -l)
if [ "$C_TEST" -ge "$B_TEST" ]; then
    echo "  S-3 PASS  test_count: $C_TEST (baseline: $B_TEST)"
else
    echo "  S-3 FAIL  test_count: $C_TEST < baseline: $B_TEST"
    FAILED=1
fi

# S-4: Feature flag count (INFO only)
C_CFG=$(grep -rn '#\[cfg(feature' crates/ --include='*.rs' | wc -l)
echo "  S-4 INFO  cfg_count: $C_CFG (baseline: $B_CFG)"

# S-5: Template count (exact) — actually count from compiled-in JSON
C_TMPL=$(python3 -c "import json; print(len(json.load(open('crates/hermetic/src/templates-community.json'))))")
if [ "$C_TMPL" -eq "$B_TMPL" ]; then
    echo "  S-5 PASS  template_count: $C_TMPL (baseline: $B_TMPL)"
else
    echo "  S-5 FAIL  template_count: $C_TMPL != baseline: $B_TMPL"
    FAILED=1
fi

# S-6: Command count (exact)
C_CMD=$(cargo run --release --bin hermetic -- --help 2>&1 | grep -cE '^  [a-z]')
if [ "$C_CMD" -eq "$B_CMD" ]; then
    echo "  S-6 PASS  cmd_count: $C_CMD (baseline: $B_CMD)"
else
    echo "  S-6 FAIL  cmd_count: $C_CMD != baseline: $B_CMD"
    FAILED=1
fi

# S-7: Binary size (<= baseline + 5%)
C_SIZE=$(stat -c%s target/release/hermetic)
MAX_SIZE=$(python3 -c "import math; print(math.ceil($B_SIZE * 1.05))")
if [ "$C_SIZE" -le "$MAX_SIZE" ]; then
    echo "  S-7 PASS  bin_size: $C_SIZE (baseline: $B_SIZE, max: $MAX_SIZE)"
else
    echo "  S-7 FAIL  bin_size: $C_SIZE > max: $MAX_SIZE (baseline: $B_SIZE + 5%)"
    FAILED=1
fi

# S-8: Sensitive information gate — blocks leaks in .md docs
echo ""
echo "  S-8 Sensitive information scan (docs)..."
S8_FAIL=0

# Exclude this script from self-matching
SELF="scripts/community-sentinel-check.sh"

# Internal doc IDs (HM-EXEC, HM-DR, etc.) in .md files
HM_COUNT=$(grep -rl 'HM-EXEC-\|HM-DR-\|HM-CERT-\|HM-CONST-\|HM-GOV-\|HM-ARCH-\|HM-FUZZ-\|HM-TEST-\|HM-VISION-\|HM-DESIGN-' --include='*.md' . 2>/dev/null | wc -l)
if [ "$HM_COUNT" -gt 0 ]; then
    echo "  S-8 FAIL  Internal doc IDs (HM-*) in .md files: $HM_COUNT"
    grep -rn 'HM-EXEC-\|HM-DR-\|HM-CERT-\|HM-CONST-' --include='*.md' . | head -5
    S8_FAIL=1
fi

# Personal identity
ID_COUNT=$(grep -rl 'vishal\|chamspter\|PH317\|darbhanga' --include='*.md' --include='*.rs' --include='*.toml' --include='*.yml' --include='*.sh' . 2>/dev/null | grep -v '.git/' | grep -v "$SELF" | wc -l)
if [ "$ID_COUNT" -gt 0 ]; then
    echo "  S-8 FAIL  Personal identity found: $ID_COUNT files"
    S8_FAIL=1
fi

# Internal paths
PATH_COUNT=$(grep -rl 'hermetic-oblivion\|/home/vishal\|Hermetic-Vault-main' --include='*.md' --include='*.rs' --include='*.toml' --include='*.yml' --include='*.sh' . 2>/dev/null | grep -v '.git/' | grep -v "$SELF" | wc -l)
if [ "$PATH_COUNT" -gt 0 ]; then
    echo "  S-8 FAIL  Internal paths found: $PATH_COUNT files"
    S8_FAIL=1
fi

# Old repo name in non-.rs files
OLD_REPO=$(grep -rl 'Hermetic-Vault' --include='*.md' --include='*.toml' --include='*.yml' --include='*.sh' . 2>/dev/null | grep -v '.git/' | grep -v "$SELF" | wc -l)
if [ "$OLD_REPO" -gt 0 ]; then
    echo "  S-8 FAIL  Old repo name (Hermetic-Vault): $OLD_REPO files"
    S8_FAIL=1
fi

# Exact metrics in docs (TPF v2)
METRICS=$(grep -rl '\b935\b\|1\.72B\|1\.6B\|\b415+\b\|69 amend\|41 amend\|46,607\|46,737\|39,154' --include='*.md' . 2>/dev/null | grep -v '.git/' | wc -l)
if [ "$METRICS" -gt 0 ]; then
    echo "  S-8 FAIL  Exact metrics in docs: $METRICS files"
    S8_FAIL=1
fi

# Competitor names
COMP=$(grep -rl 'Keycard\|MintMCP\|\bPeta\b\|CyberArk' --include='*.md' . 2>/dev/null | grep -v '.git/' | wc -l)
if [ "$COMP" -gt 0 ]; then
    echo "  S-8 FAIL  Competitor names: $COMP files"
    S8_FAIL=1
fi

# HC-16 specific: hermetic run must NOT appear in MCP tool registry
HC16=$(grep -rl '"run"\|RunTool\|run_command' crates/hermetic-mcp/src/ --include='*.rs' 2>/dev/null | wc -l)
if [ "$HC16" -gt 0 ]; then
    echo "  S-8 FAIL  HC-16 violation: hermetic run in MCP crate"
    S8_FAIL=1
fi

if [ "$S8_FAIL" -eq 0 ]; then
    echo "  S-8 PASS  No sensitive information leaks"
else
    FAILED=1
fi

echo ""
echo "══════════════════════════════════════════════════"
if [ "$FAILED" -eq 0 ]; then
    echo "  SENTINEL VERDICT: PASS"
else
    echo "  SENTINEL VERDICT: FAIL"
fi
echo "══════════════════════════════════════════════════"

exit $FAILED
