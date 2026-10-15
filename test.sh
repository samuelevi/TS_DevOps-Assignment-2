#!/usr/bin/env bash
set -u

IMAGE="diagnostic-tool"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "======================================"
echo " Assignment 2 - Student Tests"
echo "======================================"
echo

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is required to run tests."
    exit 1
fi

if ! docker build -t "$IMAGE" . >/dev/null 2>&1; then
    echo "ERROR: Docker image failed to build."
    exit 1
fi

run_test() {
    local name="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        pass "$name"
    else
        fail "$name"
    fi
}

run_test "help command works" docker run --rm "$IMAGE" help
run_test "system command works" docker run --rm "$IMAGE" system
run_test "disk command works" docker run --rm "$IMAGE" disk

docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then
    pass "invalid command returns non-zero"
else
    fail "invalid command should return non-zero"
fi

output=$(docker run --rm "$IMAGE" help 2>&1)
if echo "$output" | grep -qi "usage\|command"; then
    pass "help output contains usage information"
else
    fail "help output should contain usage information"
fi

output=$(docker run --rm "$IMAGE" system 2>&1)
if echo "$output" | grep -qi "hostname"; then
    pass "system output contains hostname"
else
    fail "system output should contain hostname"
fi

docker image rm "$IMAGE" >/dev/null 2>&1 || true

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ $FAIL -eq 0 ]]
