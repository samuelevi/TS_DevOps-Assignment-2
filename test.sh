#!/usr/bin/env bash
set -u

IMAGE="diagnostic-tool"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "======================================"
echo " Assignment 2 - Student Tests"
echo "======================================"
echo

# make sure docker is available before doing anything
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is required to run tests."
    exit 1
fi

# build the image first, bail out if it fails
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

# test each command
run_test "help command works" docker run --rm "$IMAGE" help
run_test "system command works" docker run --rm "$IMAGE" system
run_test "disk command works" docker run --rm "$IMAGE" disk

# invalid command should fail with non-zero exit code
docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then
    pass "invalid command returns non-zero"
else
    fail "invalid command should return non-zero"
fi

# check that help actually prints something useful
output=$(docker run --rm "$IMAGE" help 2>&1)
if echo "$output" | grep -qi "usage\|command"; then
    pass "help output contains usage information"
else
    fail "help output should contain usage information"
fi

# check that system shows the hostname
output=$(docker run --rm "$IMAGE" system 2>&1)
if echo "$output" | grep -qi "hostname"; then
    pass "system output contains hostname"
else
    fail "system output should contain hostname"
fi

# network with no host should exit 2
docker run --rm "$IMAGE" network >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "network without host returns exit code 2"
else
    fail "network without host should return exit code 2"
fi

# unresolvable host should exit 1
docker run --rm "$IMAGE" network does-not-exist.invalid >/dev/null 2>&1
rc=$?
if [[ $rc -eq 1 ]]; then
    pass "unresolvable host returns exit code 1"
else
    fail "unresolvable host should return exit code 1"
fi

# cleanup
docker image rm "$IMAGE" >/dev/null 2>&1 || true

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ $FAIL -eq 0 ]]