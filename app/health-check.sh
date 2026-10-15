#!/usr/bin/env bash
set -u

echo "Health Check"
echo "Status: OK"
echo "Timestamp: $(date)"

if command -v hostname >/dev/null 2>&1; then
    echo "Host: $(hostname)"
fi

exit 0
